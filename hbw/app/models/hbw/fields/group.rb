module HBW
  module Fields
    class Group < Base
      def fields
        @fields ||= definition.fetch('fields').map do |field|
          Base.wrap(field.merge('task' => task, 'entityClass' => entity_class))
        end
      end

      def as_json
        { name: name,
          type: type,
          label: label,
          css_class: css_class,
          fields: fields.map(&:as_json),
          delete_if: delete_if,
          variables: task.definition['variables'] }
      end

      def fetch
        fields.each(&:fetch)
      end

      def field(name)
        fields.find { |field| field.name == name }
      end

      def has_value?
        false
      end
    end
  end
end
