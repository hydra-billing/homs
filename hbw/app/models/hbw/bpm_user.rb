module HBW
  class BPMUser
    extend HBW::Remote
    include HBW::Definition

    class << self
      using_connection \
      def fetch(email)
        definition = do_request(:get, 'identity/users', email: email).first
        new(definition) if definition
      end

      using_connection \
      def fetch_all
        do_request(:get, 'identity/users', firstNameLike: '%').map do |definition|
          new(definition) if definition
        end.compact
      end
    end

    definition_reader :id, :email, :first_name, :last_name
  end
end
