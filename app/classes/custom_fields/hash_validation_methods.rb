module CustomFields
  module HashValidationMethods
    protected

    # error messages
    attr_writer :error_suffix

    def error_suffix
      @error_suffix ||= :definition
    end

    def t(key, *args)
      I18n.t("custom_fields.#{error_suffix}.#{key}", *args)
    end

    def add_missing_error(attribute_name)
      errors[attribute_name] ||= []
      errors[attribute_name] << t('missing_attribute', attribute_name: attribute_name)
      false
    end

    def add_unexpected_type_error(attribute_name, type)
      errors[attribute_name] ||= []
      errors[attribute_name] << t('invalid_type',
                                  attribute_name: attribute_name, type: type)
      false
    end

    def add_unknown_type_error(type)
      errors[type] ||= []
      errors[type] << t('unknown_type', type: type)
      false
    end

    def add_max_length_error(attribute_name, max_length)
      errors[attribute_name] ||= []
      errors[attribute_name] << t('max_length',
                                  attribute_name: attribute_name,
                                  max_length:     max_length)
      false
    end

    # checkings
    def key_value_should_be_of_certain_type(key, options)
      if options[:as].is_a?(Array)
        options[:as].any? { |klass| options[:in][key].is_a?(klass) }
      elsif options[:in][key].is_a?(Array)
        options[:in][key].map do |e|
          e.is_a?(options[:as])
        end
      else
        options[:in][key].is_a?(options[:as])
      end || add_unexpected_type_error(key, options[:as])
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
