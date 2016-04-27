module CustomFields
  class FieldDef < Base
    def validate_value(field_name, value)
      if @type_obj
        @type_obj.validate_value(field_name, value)

        if @type_obj.errors[field_name].present?
          errors[field_name] += @type_obj.errors[field_name]
        end
      end
    end

    def coerce_value(value)
      @type_obj.coerce_value(value)
    end

    protected

    def validate_definition
      string_fields.each do |key|
        should_have_key?(key, in: options, as: String)
      end

      boolean_fields.each do |key|
        should_have_key?(key, in: options, as: [TrueClass, FalseClass])
      end

      check_type && perform_type_specific_validations if options[:type]
    end

    def string_fields
      [:name, :type, :label]
    end

    def boolean_fields
      []
    end

    def check_type
      @type_class = field_class_from_underscore(options[:type])
      @type_class || add_unknown_type_error(options[:type])
    end

    def perform_type_specific_validations
      @type_obj = @type_class.new(options, errors) if @type_class
    end

    def field_class_from_underscore(type)
      "CustomFields::DataTypes::#{type.camelize}".safe_constantize
    end
  end
end
