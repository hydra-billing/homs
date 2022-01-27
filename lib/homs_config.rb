require 'settingslogic'

module Settings
  class Homs < Settingslogic
    source Rails.root.join('config/homs_configuration.default.yml')

    custom_config_path = Rails.root.join('config/homs_configuration.yml')

    if File.exist?(custom_config_path) && File.read(custom_config_path).present?
      custom_settings = Settings::Homs.new(custom_config_path)
      instance.deep_merge!(custom_settings)
      instance.deep_symbolize_keys!
    end

    def self.fetch(key, default = nil)
      instance[key] || default
    end
  end
end
