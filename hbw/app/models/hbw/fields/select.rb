module HBW
  module Fields
    class Select < Ordinary
      self.default_data_type = :string

      include HBW::Engine.routes.url_helpers
      attr_reader :choices

      definition_reader :sql, :variable, :entity_class

      MAX_ROW_COUNT = 20

      class SourceLoader
        include HBW::Logger

        attr_reader :name, :source, :condition, :variables

        def initialize(name, source, condition, variables)
          @name      = name
          @source    = source
          @condition = condition
          @variables = variables
        end

        def load(limit = nil)
          values = source.select(condition, variables, limit)

          logger.debug do
            "Retrieved values for %s\nfrom source %s\ncondition: %s\nvariables: %s.\nResult: %s" %
              [name, source, condition, variables, values.to_s]
          end

          values
        end
      end

      def fetch
        if select?
          @choices = definition.fetch('choices') { load_choices }
        elsif lookup?
          @choices = value ? load_lookup_value : []
        end

        if @choices.nil?
          raise ArgumentError, 'Choices for %s are not specified' % name
        end

        @choices
      end

      def as_json
        {name:        name,
         type:        type,
         mode:        mode,
         label:       label,
         css_class:   css_class,
         placeholder: placeholder,
         label_css:   label_css,
         choices:     choices,
         nullable:    nullable?,
         editable:    editable?,
         delimiter:   delimiter?,
         delete_if:   delete_if,
         disable_if:  disable_if,
         dynamic:     dynamic,
         variables:   variables,
         url:         url}
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
          lookup_task_path(task_id, name: name, entity_class: entity_class)
        end
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
        definition['placeholder']
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

      def lookup_values(query)
        choices_to_array(loader(lookup_sql, variables_hash.merge(value: query)).load(MAX_ROW_COUNT).uniq)
      end

      private

      def load_choices
        choices_to_array(loader(options_condition, variables_hash).load)
      end

      def choices_to_array(choices)
        choices.map do |variant|
          [variant.fetch(:id), variant.fetch(:text)]
        end.uniq
      end

      def source
        Sources.fetch(definition.fetch('data_source'))
      end

      def loader(condition, variables)
        SourceLoader.new(name, source, condition, variables)
      end

      def load_lookup_value
        choices_to_array(loader(lookup_value_sql, variables_hash.merge(value: value)).load)
      end

      def lookup_value_sql
        sql.sub('$condition', id_condition)
      end

      def id_condition
        definition.fetch('id_condition')
      end

      def lookup_sql
        sql.sub('$condition', filter_condition)
      end

      def filter_condition
        definition.fetch('filter_condition')
      end
    end
  end
end
