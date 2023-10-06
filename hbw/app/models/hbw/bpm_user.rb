module HBW
  class BPMUser
    extend HBW::Remote
    include HBW::Definition

    class << self
      def fetch(email)
        definition = do_request(:get, users_url, email:).first
        new(definition) if definition
      end

      def fetch_all
        do_request(:get, users_url, firstNameLike: '%').map do |definition|
          new(definition) if definition
        end.compact
      end

      def users_url
        'user'
      end
    end

    definition_reader :id, :email, :first_name, :last_name
  end
end
