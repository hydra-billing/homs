module Validations
  def self.included(action)
    action.extend ClassMethods
  end

  module ClassMethods
    def schema(&block)
      if block
        @schema = Dry::Validation.Form(&block)
      else
        @schema
      end
    end
  end

  def validate(input)
    self.class.schema.call(input.to_h)
  end
end
