module HBW
  class Variable
    include HBW::Definition

    definition_reader :value, :name

    class << self
      def wrap(variables)
        variables.map { |variable| new(variable) }
      end
    end

    def initialize(*)
      super
      @fetched = false
    end

    def to_h
      definition
    end
  end
end
