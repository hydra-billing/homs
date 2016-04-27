module HBW
  module Fields
    class Checkbox < Ordinary
      self.default_data_type = :boolean

      def coerce(value)
        case data_type
          when :boolean
            value == 'on'
          else
            fail_unsupported_coercion(value)
        end
      end
    end
  end
end
