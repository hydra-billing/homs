module HBW
  module Fields
    class Base
      include HBW::Definition

      class UnsupportedCoercion < StandardError
        def initialize(from, to)
          super('Unsupported coercion from %s to %s' % [from, to])
        end
      end

      class << self
        def wrap(definition)
          name.sub(/Base\z/, definition['type'].camelize).constantize.new(definition)
        end
      end

      class_attribute :default_data_type, instance_writer: false
      definition_reader :name, :type, :task_id, :label, :entity_class, :variables

      def css_class
        definition['css_class']
      end

      def label_css
        definition['label_css']
      end

      def fetch; end

      def data_type
        definition.fetch('data_type', default_data_type).to_sym
      end

      def type
        self.class.name.demodulize.underscore.to_sym
      end

      def code
        definition['name']
      end

      def coerce(_)
        raise NotImplementedError
      end

      def has_value?
        true
      end

      def editable?
        definition.fetch('editable', true)
      end

      def delimiter?
        definition.fetch('delimiter', false)
      end

      def delete_if
        definition.fetch('delete_if', [])
      end

      def disable_if
        definition.fetch('disable_if', [])
      end

      private

      def fail_unsupported_coercion(value)
        raise UnsupportedCoercion.new(value.class, data_type)
      end
    end
  end
end
