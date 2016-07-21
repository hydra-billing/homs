require_relative '../../hbw/app/models/hbw/activiti/yml_api'

module Imprint
  class YMLAPI < HBW::Activiti::YMLAPI
    class << self
      def build
        new(YAML.load_file(Rails.root.join('spec/imprint/config/yml_imprint_api.yml')))
      end
    end

    def choose_response(method, url, _)
      HBW::Activiti::DummyResponse.new(fetch_response(method, url))
    end

    private

    def fetch_response(method, url)
      responses.fetch(method).fetch(url)
    end
  end
end

