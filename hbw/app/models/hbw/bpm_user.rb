module HBW
  class BPMUser
    extend HBW::Remote
    include HBW::Definition

    class << self
      def fetch(email)
        definition = do_request(:get, 'user', email: email).first
        new(definition) if definition
      end

      def fetch_all
        do_request(:get, 'user', firstNameLike: '%').map do |definition|
          new(definition) if definition
        end.compact
      end
    end

    definition_reader :id, :email, :first_name, :last_name
  end
end
