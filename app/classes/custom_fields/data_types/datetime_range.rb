module CustomFields
  module DataTypes
    class DatetimeRange < CustomFields::Base
      def validate_definition
        true
      end

      def validate_value(attribute_name, value)
        return true if value.empty?
        return true if (value[:from].is_a?(Time) || value[:from].is_a?(Date)) &&
                       (value[:to].is_a?(Time)   || value[:to].is_a?(Date))

        coerce_value(value)
      rescue ArgumentError
        errors[attribute_name] << t('invalid_value',
                                    attribute_name:,
                                    type:           'DateTimeFilter',
                                    value:)
      end

      def coerce_value(value)
        unless value.is_a?(Hash)
          raise NotImplementedError
        end

        {
          from: datetime_obj.coerce_value(value[:from]),
          to:   datetime_obj.coerce_value(value[:to])
        }
      end

      def datetime_obj
        Datetime.new(options)
      end
    end
  end
end
