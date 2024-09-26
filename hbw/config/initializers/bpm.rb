require_relative '../../lib/bpm/config_validator'

Rails.application.config.to_prepare do
  HBW::Common::API.config = BPM::ConfigValidator.(config: Settings::BPM[Rails.env])
end
