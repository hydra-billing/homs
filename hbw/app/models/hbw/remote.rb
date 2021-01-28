module HBW
  module Remote
    class RemoteError < StandardError
      def initialize(path, error, backtrace = nil)
        super('Failed to make a request to %s (%s)' % [path, error])
        set_backtrace(backtrace) if backtrace
      end
    end

    class << self
      attr_accessor :connection
    end

    def with_connection(connection)
      before = Remote.connection
      Remote.connection = connection
      yield
    ensure
      Remote.connection = before
    end

    def do_request(method, *args)
      response = Remote.connection.send(method, *args)

      if [200, 204].include?(response.status)
        case response.body
        when Array then response.body
        when Hash
          if response.body.key?('data')
            response.body['data']
          else
            response.body
          end
        else
          response.body
        end
      else
        raise RemoteError.new(args[0], 'response code: %s, body: %s' % [response.status, response.body])
      end
    rescue StandardError => e
      raise RemoteError.new(args[0], e.message, e.backtrace)
    end
  end

  module RemoteWithConnection
    def do_request(method, *args)
      ensure_connection_exists
      super(method, *args)
    end

    def ensure_connection_exists
      raise "You've not provided connection!" unless Remote.connection.present?
    end
  end

  Remote.prepend RemoteWithConnection
end
