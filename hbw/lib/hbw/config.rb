module HBW
  class Config
    class << self
      def load(paths)
        paths.map! { |path| Rails.root.join(path) }

        configs = paths.select { |p| File.exists?(p) && File.read(p).present? }.map { |p| YAML.load(File.read(p)) }
        config = configs.reduce(:deep_merge).deep_symbolize_keys

        new(config)
      end
    end

    delegate :fetch, :merge, to: :@value

    def initialize(value)
      @value = value
    end

    def [](*keys)
      result = keys.reduce(@value) do |v, key|
        v.fetch(key.to_sym)
      end

      if result.is_a?(Hash)
        HBW::Config.new(result)
      else
        result
      end
    end
  end
end
