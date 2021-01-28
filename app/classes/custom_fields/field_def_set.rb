module CustomFields
  class FieldDefSet < Base
    def validate_value(_name, fields_values)
      fields_values.each do |field_name, field_value|
        fd = @fds[field_name] || @fds[field_name.intern]
        if fd.nil?
          fields_values.delete(field_name)
          fields_values.delete(field_name.intern)
          errors[field_name] << t('no_known_fields') if fields_values.empty?
          # errors << t('undefined_field', field_name: field_name)
        else
          fd.validate_value(field_name, field_value)
          errors[field_name] += fd.errors[field_name] unless fd.valid?
        end
      end
    end

    def nil_fields_values
      options.keys.each_with_object({}) do |key, h|
        h[key] = nil
      end
    end

    def coerce(values)
      options.keys.each_with_object({}) do |key, h|
        key_s = key.to_s
        h[key_s] = if values.key?(key_s) && !values.fetch(key_s).nil?
                     @fds.fetch(key).coerce_value(values.fetch(key_s))
                   end
      end
    end

    protected

    def validate_definition
      @fds = {}
      options.each do |field_name, field_params|
        next unless should_have_key?(field_name, in: options, as: Hash)

        fd = field_def_class.new(field_params.merge(name: field_name.to_s))
        if fd.valid?
          @fds[field_name] = fd
        else
          errors[field_name] << "#{field_name}: #{fd.errors.values.join(', ')}"
        end
      end
    end

    private

    def field_def_class
      FieldDef
    end
  end
end
