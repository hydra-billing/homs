module CustomFields
  module DataTypes
    class Number < CustomFields::Base
      def validate_value(attribute_name, value)
        return true if value.nil?

        valid = case value
                  when ::String then value == coerce_value(value).to_s
                  when NilClass, Numeric then true
                  else
                    false
        end

        unless valid
          errors[attribute_name] << t(:invalid, attribute_name: attribute_name, value: value)
        end
      end

      def coerce_value(value)
        case value
          when ::Numeric then value
          when ::String
            if value.empty?
              nil
            elsif value =~ /\.\d+\z/
              value.to_f
            else
              value.to_i
            end
          when ::Array then value.map { |v| coerce_value(v) }
          else
            raise NotImplementedError
        end
      end
    end
  end
end

