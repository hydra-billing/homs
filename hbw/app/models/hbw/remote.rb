module HBW
  module Remote
    include Dry::Effects.Reader(:connection)

    class RemoteError < StandardError
      def initialize(path, error, backtrace = nil)
        super('Failed to make a request to %s (%s)' % [path, error])
        set_backtrace(backtrace) if backtrace
      end
    end

    class << self
      attr_accessor :connection
    end

    def do_request(method, *args)
      response = connection.send(method, *args)

      if [200, 204].include?(response.status)
        case response.body
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
      e.instance_of?(RemoteError) ? (raise e) : (raise RemoteError.new(args[0], e.message, e.backtrace))
    end
  end

  module RemoteWithConnection
    def do_request(method, *args)
      ensure_connection_exists
      super(method, *args)
    end

    def ensure_connection_exists
      raise "You've not provided connection!" unless connection.present?
    end
  end

  Remote.prepend RemoteWithConnection
end
