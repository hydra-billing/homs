module HBW
  module Sources
    class Activiti < Base
      def select(variable_name, variables)
        value = variables.fetch(variable_name.to_sym)

        if value.present?
          JSON.load(value).map!{|item| item.deep_symbolize_keys!}
        else
          []
        end
      end
    end
  end
end
