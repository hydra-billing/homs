module HBW
  module Fields
    class Ordinary < Base
      def as_json
        definition.symbolize_keys
      end

      def value
        variables_hash[name.to_sym]
      end

      def variables_hash
        variables.map.with_object({}) do |variable, h|
          h[variable['name'].to_sym] = variable['value']
        end
      end
    end
  end
end
