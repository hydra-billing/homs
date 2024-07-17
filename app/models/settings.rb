require_relative '../../lib/config'

module Settings
  class HBW < Config
    def self.base_path
      Rails.root.join('config', 'hbw.default.yml')
    end

    def self.custom_path
      Rails.root.join('config', 'hbw.yml')
    end
  end

  class Imprint < Config
    def self.base_path
      Rails.root.join('config', 'imprint.default.yml')
    end

    def self.custom_path
      Rails.root.join('config', 'imprint.yml')
    end
  end

  class BPM < Config
    def self.base_path
      Rails.root.join('config', 'bpm.yml')
    end
  end

  class Sources < Config
    def self.base_path
      Rails.root.join('config', 'sources.yml')
    end

    def self.namespace
      :sources
    end
  end
end
