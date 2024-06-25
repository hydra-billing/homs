require 'yaml'
require 'erb'
require 'forwardable'

class Config
  def self.config
    @config ||= load_config
  end

  def self.[](key)
    config[key.to_s]
  end

  def self.[]=(key, value)
    config[key.to_s] = value
  end

  def self.fetch(key, *, &)
    config.fetch(key.to_s, *, &)
  end

  def self.each(&)
    config.each(&)
  end

  def self.load_config
    default_yaml_data = YAML.safe_load(ERB.new(File.read(base_path)).result, aliases: true)
    custom_yaml_data = {}

    if custom_path && File.exist?(custom_path) && File.read(custom_path).present?
      custom_yaml_data = YAML.safe_load(ERB.new(File.read(custom_path)).result, aliases: true)
    end

    full_config = exclusive_deep_merge(default_yaml_data, custom_yaml_data)

    result = if namespace
               path = namespace.split('.')
               full_config.dig(*path)
             else
               full_config
             end

    wrap_in_hash_wrapper(result)
  end

  def self.exclusive_deep_merge(merge_to, merge_from)
    merge_to.deep_merge(merge_from)
  end

  def self.deep_symbolize_keys
    deep_symbolize_keys_fn(config)
  end

  def self.deep_symbolize_keys_fn(obj)
    case obj
    when Hash
      obj.each_with_object({}) do |(k, v), memo|
        memo[k.to_sym] = deep_symbolize_keys_fn(v)
      end
    when Array
      obj.map { |v| deep_symbolize_keys_fn(v) }
    else
      obj
    end
  end

  def self.wrap_in_hash_wrapper(obj)
    case obj
    when Hash
      HashWrapper.new(obj.transform_values { |v| wrap_in_hash_wrapper(v) })
    else
      obj
    end
  end

  def self.base_path
    raise NotImplementedError, 'Subclasses must define base_path'
  end

  def self.custom_path
    nil
  end

  def self.namespace
    nil
  end

  def self.method_missing(name, *args, &)
    if config.key?(name.to_s)
      value = config[name.to_s]
      if value.is_a?(Hash)
        HashWrapper.new(value)
      else
        value
      end
    else
      super
    end
  end

  def self.respond_to_missing?(name, include_private = false)
    config.key?(name.to_s) || super
  end

  class HashWrapper < Hash
    def initialize(hash)
      super()
      update(hash)
    end

    def method_missing(name, *args, &)
      if key?(name.to_s)
        value = self[name.to_s]
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
      key?(name.to_s) || super
    end

    def [](key)
      super(key.to_s)
    end

    def fetch(key, *, &)
      super(key.to_s, *, &)
    end
  end
end
