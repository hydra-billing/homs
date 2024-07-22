require 'yaml'
require 'erb'
require 'forwardable'

class Config
  class << self
    def config
      @config ||= load_config
    end

    def [](key)
      config[key]
    end

    def []=(key, value)
      config[key] = value
    end

    def fetch(key, *, &)
      config.fetch(key, *, &)
    end

    def each(&)
      config.each(&)
    end

    def load_config
      default_yaml_data = YAML.safe_load(ERB.new(File.read(base_path)).result, aliases: true, symbolize_names: true)
      custom_yaml_data = {}

      if custom_path && File.exist?(custom_path) && File.read(custom_path).present?
        custom_yaml_data = YAML.safe_load(ERB.new(File.read(custom_path)).result, aliases: true, symbolize_names: true)
      end

      full_config = exclusive_deep_merge(default_yaml_data, custom_yaml_data)

      result = if namespace
                 full_config[namespace]
               else
                 full_config
               end

      wrap_in_hash(result)
    end

    def exclusive_deep_merge(merge_to, merge_from)
      merge_to.deep_merge(merge_from)
    end

    def deep_symbolize_keys
      config.deep_symbolize_keys
    end

    def wrap_in_hash(obj)
      case obj
      when Hash
        HashWrapper.wrap(obj.transform_values { |v| wrap_in_hash(v) })
      else
        obj
      end
    end

    def base_path
      raise NotImplementedError, 'Subclasses must define base_path'
    end

    def custom_path
      nil
    end

    def namespace
      nil
    end

    def method_missing(name, *args, &)
      if config.key?(name)
        value = config[name]
        if value.is_a?(Hash)
          HashWrapper.wrap(value)
        else
          value
        end
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      config.key?(name) || super
    end
  end

  class HashWrapper < HashWithIndifferentAccess
    def self.wrap(hash)
      new.update(hash)
    end

    def method_missing(name, *args, &)
      if key?(name)
        value = self[name]
        if value.is_a?(Hash)
          self.class.new(value)
        else
          value
        end
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      key?(name) || super
    end
  end
end
