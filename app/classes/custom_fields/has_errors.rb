module CustomFields
  module HasErrors
    attr_accessor :errors

    def valid?
      errors.empty?
    end
  end
end
