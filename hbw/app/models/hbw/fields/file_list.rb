module HBW
  module Fields
    class FileList < Ordinary
      self.default_data_type = :string

      def has_value?
        false
      end
    end
  end
end
