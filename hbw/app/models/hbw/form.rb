module HBW
  class Form
    extend HBW::Remote
    include HBW::Definition

    class << self
      def fetch(task_id, entity_class)
        variables      = do_request(:get, "task/#{task_id}/variables")
        definition_raw = do_request(:get, "task/#{task_id}/deployed-form")

        definition = YAML.load(definition_raw).fetch('form')

        new(definition.merge('variables'   => variables.map { |k, v| v.merge('name' => k) },
                             'taskId'      => task_id,
                             'entityClass' => entity_class)).tap(&:fetch_fields!)
      end
    end

    definition_reader :variables, :task_id, :entity_class

    def css_class
      definition.fetch('css_class', '')
    end

    def as_json
      { css_class: css_class,
        fields: fields.map(&:as_json),
        variables: variables }
    end

    def fields
      @fields ||= definition.fetch('fields').map do |field|
        Fields::Base.wrap(field.merge('variables'   => variables,
                                      'taskId'      => task_id,
                                      'entityClass' => entity_class))
      end
    end

    def fetch_fields!
      fields.each(&:fetch)
    end

    def field(name)
      flatten_fields.find do |field|
        next if field.type == 'group'

        field.name == name
      end
    end

    def extract_and_coerce_values(values)
      flatten_fields.select(&:has_value?).select(&:editable?).each_with_object({}) do |field, result|
        result[field.code] = field.coerce(values[field.code])
      end
    end

    def flatten_fields
      fields.flat_map do |field|
        field.type == :group ? field.fields : field
      end
    end
  end
end
