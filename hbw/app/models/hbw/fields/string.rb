module HBW
  module Fields
    class String < Ordinary
      self.default_data_type = :string

      def coerce(value)
        case data_type
        when :string then value
        else
          fail_unsupported_coercion(value)
        end
      end
    end
  end
end
