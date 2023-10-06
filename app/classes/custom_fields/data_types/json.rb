module CustomFields
  module DataTypes
    class Json < CustomFields::Base
      def validate_definition
        true # no need of special check
      end

      def validate_value(attribute_name, value)
        JSON.parse(value) if value.present?
      rescue JSON::ParserError => _e
        errors[attribute_name] << t(:incorrect_format,
                                    attribute_name:,
                                    value:)
      end

      def coerce_value(value)
        value
      end
    end
  end
end
