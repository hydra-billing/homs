module CustomFields
  class Base
    include HasErrors
    include HasOptions
    include HashValidationMethods

    def initialize(options, errors = {})
      self.options = options
      self.errors  = wrap_errors(errors)

      validate_definition
    end

    def validate_definition
      # override
    end

    def validate_value(*_args)
      # override
    end

    def coerce_value(value)
      raise NotImplementedError
    end

    private

    def wrap_errors(errors)
      Hash.new do |h, field|
        h[field] = []
      end.merge(errors)
    end
  end
end
