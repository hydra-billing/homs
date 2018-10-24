module HBW
  module Sources
    class Oracle < Base
      class ConnectionFailed < RuntimeError
      end


      def initialize(*)
        require 'oci8' unless defined?(OCI8)

        super
      end

      def select(sql, variables)
        binds = parse_bind_names(sql)

        execute(sql) do |cursor|
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

      def parse_bind_names(sql)
        sql.scan(/:\w+/).map { |s| s[1..-1].to_sym }
      end

      def execute(sql)
        2.times do
          begin
            establish_connection
            return try_query(sql) { |c| yield(c) if block_given? }
          rescue ConnectionFailed
            reconnect
          end
        end
      end

      def try_query(sql)
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

      def establish_connection
        return if @connection.present?
        @connection = OCI8.new(
          config.fetch('username'),
          config.fetch('password'),
          config.fetch('tns_name'))
      rescue OCIError => error
        if error.code.in?([12541])
          raise ConnectionFailed.new('Oracle connection error: %s' % error)
        else
          raise
        end
      end

      def reconnect
        @connection = nil
        establish_connection
      end
    end
  end
end
