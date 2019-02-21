require_relative '../../hbw/app/models/hbw/camunda/yml_api'

module Imprint
  class YMLAPI < HBW::Camunda::YMLAPI
    class << self
      def build
        new(YAML.load_file(Rails.root.join('spec/imprint/config/yml_imprint_api.yml')))
      end
    end

    def choose_response(method, url, _)
      Imprint::DummyResponse.new(fetch_response(method, url))
    end

    private

    def fetch_response(method, url)
      responses.fetch(method).fetch(url)
    end
  end

  class DummyResponse
    attr_accessor :body, :status, :headers

    def initialize(data)
      @body    = data['body']
      @headers = data['headers'].symbolize_keys
      @status  = 200
    end
  end
end

