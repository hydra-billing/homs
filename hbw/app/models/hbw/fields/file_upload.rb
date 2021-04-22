module HBW
  module Fields
    class FileUpload < Ordinary
      def value?
        true
      end

      def coerce(value)
        value
      end
    end
  end
end
