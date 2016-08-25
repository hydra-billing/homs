module HBW
  module Fields
    class Select < Ordinary
      self.default_data_type = :string

      include HBW::Engine.routes.url_helpers
      attr_reader :choices
      definition_reader :sql
      definition_reader :variable

      def fetch
        if select?
          @choices = definition.fetch('choices') { load_choices }
        elsif lookup? && value.present?
          @choices = load_lookup_value
        end
      end

      def as_json
        { name: name,
          type: type,
          mode: mode,
          label: label,
          css_class: css_class,
          placeholder: placeholder,
          label_css: label_css,
          choices: choices,
          nullable: select? && nullable?,
          editable: editable?,
          delimiter: delimiter?,
          url: url }
      end

      def mode
        definition.fetch('mode', 'select')
      end

      def select?
        mode == 'select'
      end

      def lookup?
        mode == 'lookup'
      end

      def url
        if lookup?
          lookup_task_path(task.id, name: name)
        end
      end

      def lookup_values(query)
        values = task.variables_hash.merge(value: query)
        source.select(lookup_sql, values).uniq
      end

      def lookup_sql
        sql.sub('$condition', filter_condition)
      end

      def choices_sql
        sql if definition.key?('sql')
      end

      def choices_variable
        variable if definition.key?('variable')
      end

      def options_condition
        choices_sql || choices_variable
      end

      def placeholder
        definition.fetch('placeholder', '')
      end

      def coerce(value)
        case data_type
          when :string
            value.presence
          else
            fail_unsupported_coercion(value)
        end
      end

      def nullable?
        definition.fetch('nullable', true)
      end

      private

      def load_choices
        choices_to_array(source.select(options_condition, task.variables_hash))
      end

      def choices_to_array(choices)
        choices.map do |variant|
          [variant.fetch(:id), variant.fetch(:text)]
        end.uniq
      end

      def filter_condition
        definition.fetch('filter_condition')
      end

      def id_condition
        definition.fetch('id_condition')
      end

      def source
        Sources.fetch(definition.fetch('data_source'))
      end

      def lookup_value_sql
        sql.sub('$condition', id_condition)
      end

      def load_lookup_value
        choices_to_array(source.select(lookup_value_sql, task.variables_hash.merge(value: value)))
      end
    end
  end
end
