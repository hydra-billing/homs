module CustomFields
  module DataTypes
    class Number < CustomFields::Base
      TRAILING_ZEROS_REGEX = /(\.\d*?)0+$/
      TRAILING_DOT_REGEX = /\.$/

      def validate_value(attribute_name, value)
        return true if value.nil?

        valid = case value
                when ::String then valid_number_string?(value)
                when NilClass, Numeric then true
                else
                  false
                end

        unless valid
          errors[attribute_name] << t(:invalid, attribute_name:, value:)
        end
      end

      def coerce_value(value)
        case value
        when ::Numeric then value
        when ::String then string_to_number(value)
        when ::Array then value.map { |v| coerce_value(v) }
        else
          raise NotImplementedError
        end
      end

      private

      def normalize_trailing_zeros(str)
        str.gsub(TRAILING_ZEROS_REGEX, '\1').gsub(TRAILING_DOT_REGEX, '')
      end

      def valid_number_string?(str)
        normalized = normalize_trailing_zeros(str)
        coerced = coerce_value(normalized)
        return false if coerced.nil?

        normalized == coerced.to_s
      end

      def string_to_number(str)
        return nil if str.empty?

        str.include?('.') ? str.to_f : str.to_i
      end
    end
  end
end
