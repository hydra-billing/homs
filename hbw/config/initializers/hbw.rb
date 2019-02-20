require 'settings'

Rails.application.config.to_prepare do
  HBW::Sources.load

  HBW::Widget.config = HBW::Config.new(Settings::HBW.deep_symbolize_keys)[:hbw]
end
