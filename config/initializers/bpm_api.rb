require 'faraday_middleware/response_middleware'

Rails.application.config.to_prepare do
  config = YAML.load_file('config/bpm.yml')[Rails.env] || {}
  config.deep_symbolize_keys!
  HBW::Activiti::API.config = config
end
