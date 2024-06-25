require_relative 'config'

module Settings
  class Homs < Config
    def self.base_path
      Rails.root.join('config', 'homs_configuration.default.yml')
    end

    def self.custom_path
      Rails.root.join('config', 'homs_configuration.yml')
    end
  end
end
