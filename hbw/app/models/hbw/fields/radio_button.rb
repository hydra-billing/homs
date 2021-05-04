module HBW
  module Fields
    class RadioButton < Ordinary
      def value?
        true
      end

      def coerce(value)
        value
      end
    end
  end
end
