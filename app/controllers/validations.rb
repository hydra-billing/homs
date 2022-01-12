module Validations
  def self.included(action)
    action.extend ClassMethods
  end

  module ClassMethods
    def contract(&block)
      if block
        @contract = Class.new(Dry::Validation::Contract, &block).new
      else
        @contract
      end
    end
  end

  def validate(input)
    self.class.contract.call(input.to_h)
  end
end
