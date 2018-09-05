module HBW
  class Form
    extend HBW::Remote
    include HBW::Definition

    class << self
      def activiti?
        HBW::Widget.config.fetch(:adapter) == 'activiti'
      end

      def fetch(task, entity_class)
        process_definition = task.process_definition

        if activiti?
          deployment = ::HBW::Deployment.fetch(process_definition)
          resource = deployment.resource(task.form_key)

          if resource.nil?
            raise ArgumentError.new(I18n.t('activerecord.errors.models.order.attributes.data.form_key_missed_in_task', form_key: task.form_key))
          end

          definition_raw = do_request(:get, resource.fetch('contentUrl'))
        else
          definition_raw = do_request(:get, "/rest/task/#{task.id}/deployed-form")
        end

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
