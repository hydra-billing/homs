module HBW
  module Sources
    class Oracle < Base
      # ORA-00028: your session has been killed
      # ORA-03113: end-of-file on communication channel
      # ORA-03114: not connected to ORACLE
      # ORA-03135: connection lost contact
      # ORA-12541: TNS no listener
      CONNECTION_ERROR_CODES = [28, 3113, 3114, 3135, 12541].freeze

      class ConnectionFailed < RuntimeError
      end

      def initialize(*)
        require 'oci8' unless defined?(OCI8)

        super
      end

      def select(sql, variables, limit = nil)
        binds = parse_bind_names(sql)

        execute(sql, limit) do |cursor|
          binds.each do |bind|
            if variables.fetch(bind).nil?
              cursor.bind_param(bind, nil, Integer)
            else
              cursor.bind_param(bind, variables.fetch(bind))
            end
          end
        end
      end

      private

      def with_connection_errors_handler
        yield
      rescue OCIError => error
        if CONNECTION_ERROR_CODES.include?(error.code)
          raise ConnectionFailed.new('Oracle connection error: %s' % error)
        else
          raise
        end
      end

      def parse_bind_names(sql)
        sql.scan(/:\w+/).map { |s| s[1..-1].to_sym } - [:HH, :HH12, :HH24, :MI, :SS, :SSSS, :SSTZH, :TZH, :TZM]
      end

      def execute(sql, limit = nil)
        2.times do
          begin
            establish_connection
            if limit.nil?
              return try_query(sql) { |c| yield(c) if block_given? }
            else
              return try_query(limit(sql, limit)) { |c| yield(c) if block_given? }
            end
          rescue ConnectionFailed
            reconnect
          end
        end
      end

      def try_query(sql)
        with_connection_errors_handler do
          begin
            cursor = @connection.parse(sql)
            yield(cursor)
            cursor.exec

            id_col, name_col = cursor.get_col_names
            name_col ||= id_col
            integer_id = id_col =~ /_id\z/i
            rows = []
            while r = cursor.fetch_hash
              rows << r
            end

            rows.map do |row|
              if integer_id
                id = row[id_col].to_i
              else
                id = row[id_col]
              end
              { id: id, text: row[name_col] }.merge(row)
            end
          ensure
            cursor.close if cursor.present?
          end
        end
      end

      def establish_connection
        return if @connection.present?

        with_connection_errors_handler do
          @connection = OCI8.new(
            config.fetch('username'),
            config.fetch('password'),
            config.fetch('tns_name'))
        end
      end

      def reconnect
        @connection = nil
        establish_connection
      end

      def limit(sql, max_row_count)
        "SELECT * FROM (#{sql}) WHERE ROWNUM <= #{max_row_count}"
      end
    end
  end
end
