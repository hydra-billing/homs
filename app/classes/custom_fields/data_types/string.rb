module CustomFields
  module DataTypes
    class String < CustomFields::Base
      MAX_LENGTH = 255

      def validate_definition
        may_have_key?(:default, in: options, as: ::String) && (
          options[:default].length <= MAX_LENGTH ||
          add_max_length_error(:default, MAX_LENGTH)
        )
        may_have_key?(:max_length, in: options, as: ::Integer) && (
          options[:max_length] <= MAX_LENGTH ||
          add_max_length_error(:max_length, MAX_LENGTH)
        )
        may_have_key?(:mask, in: options, as: ::String)
      end

      def validate_value(attribute_name, value)
        return true if value.nil?

        should_have_key?(attribute_name, in: { attribute_name => value },
                                        as: ::String) &&
          (value.length <= MAX_LENGTH ||
            add_max_length_error(attribute_name, MAX_LENGTH))
      end

      def coerce_value(value)
        case value
          when ::String then value
          when ::Numeric then value.to_s
          when ::Time, ::Date then value.iso8601
          else
            raise NotImplementedError
        end
      end
    end
  end
end
