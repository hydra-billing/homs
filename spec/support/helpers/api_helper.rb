module Features
  module APIHelper
    CAMUNDA_GLOBAL_MOCK = 'spec/support/camunda_global_mock.yml'.freeze

    def set_camunda_api_mock_file(path_to_mock)
      HBW::Container.stub(:api, [HBW::Camunda::YMLAPI.with_global(path_to_mock, CAMUNDA_GLOBAL_MOCK)])
    end

    def set_candidate_starters(value)
      HBW::Widget.config.set(:candidate_starters, {enabled: value})
    end
  end
end
