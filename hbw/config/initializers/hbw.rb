require 'settings'
require 'hbw/config_validator'

Rails.application.config.to_prepare do
  HBW::Sources.load

  validated_config = HBW::ConfigValidator.(Settings::HBW.deep_symbolize_keys)

  HBW::Widget.config = HBW::Config.new(validated_config.to_h)[:hbw]

  Rails.application.config.action_cable.mount_path = '/widget/cable'

  Rails.application.config.action_cable.allowed_request_origins = HBW::Widget.config[:allowed_request_origins].map { |url| Regexp.new(url) }
end
