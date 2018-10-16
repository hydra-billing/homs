require 'settingslogic'

module Settings
  class HBW < Settingslogic
    source Rails.root.join('config/hbw.default.yml')

    custom_config_path = Rails.root.join('config/hbw.yml')

    if File.exists?(custom_config_path) && File.read(custom_config_path).present?
      instance.deep_merge!(Settings::HBW.new(custom_config_path))
    end
  end

  class Imprint < Settingslogic
    source Rails.root.join('config/imprint.default.yml')

    custom_config_path = Rails.root.join('config/imprint.yml')

    if File.exists?(custom_config_path) && File.read(custom_config_path).present?
      instance.deep_merge!(Settings::Imprint.new(custom_config_path))
    end
  end

  class BPM < Settingslogic
    source Rails.root.join('config/bpm.yml')
  end

  class Sources < Settingslogic
    source Rails.root.join('config/sources.yml')
    namespace 'sources'
  end
end
