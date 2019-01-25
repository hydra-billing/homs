require 'faraday_middleware/response_middleware'

Rails.application.config.to_prepare do
  HBW::Common::API.load
end
