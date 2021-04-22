module ValidationsArbitraryKeys
  include ::Validations

  def self.included(action)
    action.extend ClassMethods
  end

  def validate_arbitrary_keys(input)
    validated = validate_input(input)

    if validated[:errors].keys.empty?
      [:success, validated[:data]]
    else
      [:failure, validated[:errors]]
    end
  end

  private

  def validate_input(input)
    input.each_with_object({data: {}, errors: {}}) do |(k, v), acc|
      result = validate(v)

      if result.success?
        acc[:data][k] = result.to_h
      else
        acc[:errors][k] = result.errors
      end
    end
  end
end
