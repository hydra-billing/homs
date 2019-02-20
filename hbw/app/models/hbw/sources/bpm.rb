module HBW
  module Sources
    class BPM < Base
      def select(variable_name, variables, _ = nil)
        value = variables.fetch(variable_name.to_sym)

        if value.present?
          JSON.load(value).map!(&:deep_symbolize_keys!)
        else
          []
        end
      end
    end
  end
end
