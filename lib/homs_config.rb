class HomsConfig
  class << self
    def load(paths)
      paths.map! { |path| Rails.root.join(path) }

      configs = paths.select { |p| File.exists?(p) && File.read(p).present? }.map { |p| YAML.load(File.read(p)) }
      config = configs.reduce(:deep_merge).deep_symbolize_keys

      new(config)
    end

    def config_key(*keys)
      keys.each do |key|
        define_method(key) { self[key] }
      end
    end
  end

  config_key :locale
  delegate :[], :fetch, to: :@value

  def initialize(value)
    @value = value
  end
end
