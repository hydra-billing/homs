module HBW
  class Form
    extend HBW::Remote
    include HBW::Definition

    class << self
      def fetch(task, entity_class)
        process_definition = task.process_definition

        definition_raw = do_request(:get, "task/#{task.id}/deployed-form")

        definition = YAML.load(definition_raw).fetch('form')
        new(definition.merge('processDefinition' => process_definition, 'task' => task, 'entityClass' => entity_class))
      end
    end

    definition_reader :process_definition, :task, :entity_class

    def process_name
      process_definition.name
    end

    def css_class
      definition.fetch('css_class', '')
    end

    def as_json
      { css_class: css_class,
        processName: process_name,
        fields: fields.map(&:as_json) }
    end

    def fields
      @fields ||= definition.fetch('fields').map do |field|
        Fields::Base.wrap(field.merge('task' => task, 'entityClass' => entity_class))
      end
    end

    def fetch_fields
      fields.each(&:fetch)
    end

    def field(name)
      flatten_fields.find do |field|
        next if field.type == 'group'
        field.name == name
      end
    end

    def extract_and_coerce_values(values)
      fields_for_submit(values).each_with_object({}) do |field, result|
        result[field.code] = field.coerce(values[field.code])
      end
    end

    def flatten_fields
      fields.flat_map do |field|
        field.type == :group ? field.fields : field
      end
    end

    def fields_for_submit(values)
      flatten_fields.select(&:has_value?).select(&:editable?).select { |f| values.key?(f.code) }
    end
  end
end
