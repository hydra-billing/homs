module Features
  module ApiHelper
    def set_camunda_api_mock_file(path_to_mock)
      HBW::Container.stub(:api, HBW::Camunda::YMLAPI.build(path_to_mock))
    end
  end
end
