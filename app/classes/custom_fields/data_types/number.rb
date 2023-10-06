module CustomFields
  module DataTypes
    class Number < CustomFields::Base
      def validate_value(attribute_name, value)
        return true if value.nil?

        valid = case value
                when ::String then value.gsub(/(\.)?0+$/, '') == coerce_value(value).to_s
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

      def string_to_number(str)
        if str.empty?
          nil
        elsif str =~ /\.\d+\z/
          str.to_f
        else
          str.to_i
        end
      end
    end
  end
end
