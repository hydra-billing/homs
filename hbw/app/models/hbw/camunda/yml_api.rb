module HBW
  module Camunda
    class YMLAPI < ::HBW::Common::YMLAPI
      attr_accessor :process_keys

      class << self
        def build(path)
          new(YAML.load_file(path, aliases: true), [])
        end

        def for_prosess_keys(path, process_keys)
          new(YAML.load_file(path, aliases: true), process_keys)
        end
      end

      def initialize(responses, process_keys)
        super(responses)
        @process_keys = process_keys
      end

      def process_supported?(key)
        if process_keys.empty?
          true
        else
          process_keys.include?(key)
        end
      end
    end
  end
end
