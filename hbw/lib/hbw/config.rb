module HBW
  class Config
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

    def set(key, value)
      @value[key] = value
    end
  end
end
