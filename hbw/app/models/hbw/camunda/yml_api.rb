module HBW
  module Camunda
    class YMLAPI < ::HBW::Common::YMLAPI
      attr_accessor :process_keys

      class << self
        def build(path)
          from_file(path)
        end

        def for_prosess_keys(path, process_keys)
          from_file(path, process_keys)
        end

        def with_global(path, global)
          responses = merge_responses(load_file(global), load_file(path))
          log_stub("#{path} + global #{global}")
          new(responses, [])
        end

        private

        def from_file(path, process_keys = [])
          log_stub(path + (process_keys.empty? ? '' : " #{process_keys.inspect}"))
          new(load_file(path), process_keys)
        end

        def load_file(path)
          YAML.load_file(path, aliases: true)
        end

        def log_stub(desc)
          Rails.logger.info("[camunda-mock] stub <- #{desc}")
        end

        # Combine two {method => {url => [entry]}} mocks. `overlay` entries come before `base` so
        # fetch_response's find-by-params returns them first: the test mock wins and the global mock
        # only fills endpoints or params the test mock does not define.
        def merge_responses(base, overlay)
          # Not Array(): Array(Hash) splits it into [key, value] pairs instead of wrapping it.
          entries = lambda do |mock, method, url|
            case (found = mock.dig(method, url))
            when nil   then []
            when Array then found
            else            [found]
            end
          end

          (base.keys | overlay.keys).to_h do |method|
            urls = (base[method] || {}).keys | (overlay[method] || {}).keys
            merged = urls.to_h do |url|
              [url, entries.call(overlay, method, url) + entries.call(base, method, url)]
            end
            [method, merged]
          end
        end
      end

      def initialize(responses, process_keys)
        super(responses)
        @process_keys = process_keys
      end

      def process_supported?(key)
        process_keys.empty? || process_keys.include?(key)
      end
    end
  end
end
