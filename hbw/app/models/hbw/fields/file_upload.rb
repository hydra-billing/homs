module HBW
  module Fields
    class FileUpload < Ordinary
      def has_value?
        false
      end
    end
  end
end
