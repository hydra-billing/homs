module HBW
  module Fields
    class Ordinary < Base
      def as_json
        definition.symbolize_keys
      end

      def value
        task.variables_hash[name.to_sym]
      end
    end
  end
end
