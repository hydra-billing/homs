module HBW
  module Remote
    class RemoteError < StandardError
      def initialize(path, error, backtrace = nil)
        super('Failed to make a request to %s (%s)' % [path, error])
        set_backtrace(backtrace) if backtrace
      end
    end

    module SingletonMethods
      def using_connection(method_name)
        class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def #{method_name}_with_connection(*args)
            ensure_connection_exists
            #{method_name}_without_connection(*args)
          end
        RUBY
        alias_method_chain method_name, :connection
      end
    end

    class << self
      attr_accessor :connection

      def extended(base)
        base.singleton_class.extend(SingletonMethods)
        super
      end
    end

    def with_connection(connection)
      before = Remote.connection
      Remote.connection = connection
      yield
    ensure
      Remote.connection = before
    end

    def ensure_connection_exists
      raise "You've not provided connection!" unless Remote.connection.present?
    end

    def do_request(method, *args)
      response = Remote.connection.send(method, *args)

      if response.status == 200
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
    rescue => error
      raise RemoteError.new(args[0], error.message, error.backtrace)
    end
  end
end
