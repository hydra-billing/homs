module CustomFields
  module DataTypes
    class Datetime < CustomFields::Base
      def validate_definition
        true # no need of special check
      end

      def validate_value(attribute_name, value)
        return true if value.blank?
        return true if value.is_a?(Time) || value.is_a?(Date)

        Time.iso8601(value)
      rescue ArgumentError
        errors[attribute_name] << t('invalid_value',
                                    attribute_name:,
                                    type:           'DateTime',
                                    value:)
      end

      def coerce_value(value)
        case value
        when ::String, ::Date, ::Time
          if value.empty?
            nil
          else
            ::Time.iso8601(value)
          end
        when ::Array then value.map { |v| coerce_value(v) }
        else raise NotImplementedError
        end
      end
    end
  end
end
