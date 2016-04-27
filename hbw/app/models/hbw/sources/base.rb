module HBW
  module Sources
    class Base
      attr_reader :name, :config

      def initialize(name, config)
        @name = name
        @config = config
      end

      def query(field, query)
        raise NotImplementedError
      end
    end
  end
end
