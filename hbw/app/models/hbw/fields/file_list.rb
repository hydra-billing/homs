module HBW
  module Fields
    class FileList < Ordinary
      def has_value?
        true
      end

      def coerce(value)
        value
      end
    end
  end
end
