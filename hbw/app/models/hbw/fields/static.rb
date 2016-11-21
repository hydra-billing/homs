module HBW
  module Fields
    class Static < Ordinary
      self.default_data_type = :string

      def as_json
        result = definition.symbolize_keys.dup
        result[:html] = prepare_string(result[:html])
        result
      end

      def prepare_string(str)
        str.gsub(/\$\w*\b?/) { |s| prepare_value(s) }
      end

      def prepare_value(str)
        variable = task.definition['variables'].find { |v| v['name'] == str.gsub('$', '') }

        if variable.nil?
          str
        else
          variable['value']
        end
      end

      def has_value?
        false
      end
    end
  end
end
