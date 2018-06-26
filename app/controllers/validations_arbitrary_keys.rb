module ValidationsArbitraryKeys
  include ::Validations

  def self.included(action)
    action.extend ClassMethods
  end

  def validate_arbitrary_keys(input)
    result_data = {}
    errors = {}

    input.each do |k, v|
      result = validate(v)
      if result.success?
        result_data[k] = result.to_h
      else
        errors[k] = result.errors
      end
    end

    if errors.keys.length > 0
      return :failure, errors
    else
      return :success, result_data
    end
  end
end
