require 'settings'

Rails.application.config.to_prepare do
  HBW::Sources.load

  HBW::Widget.config = HBW::Config.new(Settings::HBW.deep_symbolize_keys)[:hbw]

  if HBW::Widget.config.fetch(:adapter) == 'activiti'
    warn '[DEPRECATION] "activiti" adapter is deprecated and will be removed from HBW 1.7.0'
  end
end
