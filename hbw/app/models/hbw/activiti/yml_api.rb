module HBW
  module Activiti
    class YMLAPI
      attr_accessor :responses

      class << self
        def build(yml_api_file_path)
          new(YAML.load_file(yml_api_file_path))
        end
      end

      def initialize(responses)
        @responses = responses
      end

      %w(get put patch post delete).each do |method|
        define_method method do |url, *params|
          choose_response(method, url, *params)
        end
      end

      def choose_response(method, url, params = {})
        HBW::Activiti::DummyResponse.new(fetch_response(method, url, params))
      end

      def load(response_file_path)
        if File.exists?(response_file_path)
          new_responses = YAML.load_file(response_file_path)
        else
          new_responses = {}
        end

        @responses = new_responses.deep_merge(new_responses)
      end

      private

      def fetch_response(method, url, params)
        responses.fetch(method).fetch(url).fetch(URI.unescape(params.to_query))
      end
    end

    class DummyResponse
      attr_accessor :body, :status

      def initialize(data)
        @body   = data
        @status = 200
      end
    end
  end
end
