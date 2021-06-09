module HBW
  module Definition
    extend ActiveSupport::Concern

    module ClassMethods
      def definition_reader(*names)
        names.each do |name|
          key = name.to_s.camelize(:lower)
          class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
            def #{name}                   # def id
              definition.fetch('#{key}')  #   definition.fetch('id')
            end                           # end
          RUBY
        end
      end
    end

    attr_reader :definition

    delegate :config, to: 'HBW::Widget'

    def initialize(definition)
      @definition = definition
    end
  end
end
