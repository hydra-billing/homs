module HBW
  module Fields
    class User < Ordinary
      self.default_data_type = :string

      def as_json
        json = super.dup
        json[:variables] = variables
        json
      end
    end
  end
end
