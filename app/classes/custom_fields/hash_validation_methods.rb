module CustomFields
  module HashValidationMethods
    protected

    # error messages
    attr_writer :error_suffix

    def error_suffix
      @error_suffix ||= :definition
    end

    def t(key, **)
      I18n.t("custom_fields.#{error_suffix}.#{key}", **)
    end

    def add_missing_error(attribute_name)
      errors[attribute_name] ||= []
      errors[attribute_name] << t('missing_attribute', attribute_name:)
      false
    end

    def add_unexpected_type_error(attribute_name, type)
      errors[attribute_name] ||= []
      errors[attribute_name] << t('invalid_type',
                                  attribute_name:, type:)
      false
    end

    def add_unknown_type_error(type)
      errors[type] ||= []
      errors[type] << t('unknown_type', type:)
      false
    end

    def add_max_length_error(attribute_name, max_length)
      errors[attribute_name] ||= []
      errors[attribute_name] << t('max_length',
                                  attribute_name:,
                                  max_length:)
      false
    end

    # checkings
    def validate_array_as(key, options)
      options[:as].any? { |klass| options[:in][key].is_a?(klass) }
    end

    def validate_array_in(key, options)
      options[:in][key].map { |e| e.is_a?(options[:as]) }
    end

    def validate_key_value_type(key, options)
      if options[:as].is_a?(Array)
        validate_array_as(key, options)
      elsif options[:in][key].is_a?(Array)
        validate_array_in(key, options)
      else
        options[:in][key].is_a?(options[:as])
      end
    end

    def key_value_should_be_of_certain_type(key, options)
      validate_key_value_type(key, options) || add_unexpected_type_error(key, options[:as])
    end

    def should_have_key?(key, options)
      (options[:in].key?(key) || add_missing_error(key)) &&
        key_value_should_be_of_certain_type(key, options)
    end

    def may_have_key?(key, options)
      options[:in].key?(key) &&
        key_value_should_be_of_certain_type(key, options)
    end
  end
end
