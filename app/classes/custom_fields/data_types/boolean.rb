module CustomFields
  module DataTypes
    class Boolean < CustomFields::Base
      STRING_VALUES = {
        true  => %w(true on 1),
        false => %w(false off 0)
      }.freeze

      def validate_definition
        check_default
      end

      def validate_value(attribute_name, value)
        return true if value.in?(STRING_VALUES.values.flatten)
        return true if value.class.in?([TrueClass, FalseClass, NilClass])

        errors[attribute_name] << t(:not_in_set, attribute_name: attribute_name,
                                                 value:          value,
                                                 set:            STRING_VALUES[true].zip(STRING_VALUES[false]).flatten)
      end

      def coerce_value(value)
        case value
        when ::FalseClass, ::TrueClass then value
        when ::String then value.in?(STRING_VALUES[true])
        when ::Numeric then !value.zero?
        else
          raise NotImplementedError
        end
      end

      protected

      def check_default
        may_have_key?(:default, in: options, as: [TrueClass, FalseClass])
      end
    end
  end
end
