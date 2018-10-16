require 'settings'

module HBW
  module Sources
    extend self

    @sources = {}

    def load
      Settings::Sources.each do |source_name, source_config|
        source = build_source(source_name, source_config)
        register(source)
      end
    end

    def build_source(source_name, source_config)
      type = source_config.fetch('type')

      klass = case type
              when 'sql/oracle'
                HBW::Container[:oracle]
              when 'static/activiti'
                HBW::Sources::Activiti
              else
                raise ArgumentError.new('Unknown source type %s: %s' % [source_name, type])
              end

      klass.new(source_name, source_config)
    end

    def register(source)
      if @sources.key?(source.name)
        raise ArgumentError.new('Source %s already registered' % source.name)
      end
      @sources[source.name] = source
    end

    def fetch(name)
      @sources.fetch(name)
    end
  end
end
