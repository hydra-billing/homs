module HBW
  module Fields
    class Group < Base
      def fields
        @fields ||= definition.fetch('fields').map do |field|
          Base.wrap(field.merge('variables'   => variables,
                                'taskId'      => task_id,
                                'entityClass' => entity_class))
        end
      end

      def as_json
        {name:,
         type:,
         label:,
         css_class:,
         fields:     fields.map(&:as_json),
         delete_if:,
         disable_if:,
         dynamic:,
         variables:}
      end

      def fetch
        fields.each(&:fetch)
      end

      def field(name)
        fields.find { |field| field.name == name }
      end

      def value?
        false
      end
    end
  end
end
