module CustomFields
  module DataTypes
    class Json < CustomFields::Base
      def validate_definition
        true # no need of special check
      end

      def validate_value(attribute_name, value)
        JSON.load(value) if value.present?
      rescue JSON::ParserError => _error
        errors[attribute_name] << t(:incorrect_format,
                                    attribute_name: attribute_name,
                                    value: value)
      end

      def coerce_value(value)
        value
      end
    end
  end
end
