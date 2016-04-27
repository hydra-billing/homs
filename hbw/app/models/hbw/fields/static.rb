module HBW
  module Fields
    class Static < Ordinary
      self.default_data_type = :string

      def has_value?
        false
      end
    end
  end
end
