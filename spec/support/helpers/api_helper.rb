module Features
  module ApiHelper
    def set_camunda_api_mock_file(path_to_mock)
      HBW::Container.stub(:api, HBW::Camunda::YMLAPI.build(path_to_mock))
    end

    def set_candidate_starters(value)
      HBW::Widget.config.set(:candidate_starters, {enabled: value})
    end
  end
end
