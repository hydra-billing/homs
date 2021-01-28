module HBW
  module Fields
    class Datetime < Ordinary
      self.default_data_type = :string

      def coerce(value)
        return if value.blank?

        time = case value
               when ::String then ::Time.iso8601(value)
               when ::Date, ::Time then value.to_time
               when ::Time then value
               else raise NotImplementedError
               end

        case data_type
        when :string then time.iso8601
        else
          fail_unsupported_coercion(value)
        end
      end
    end
  end
end
