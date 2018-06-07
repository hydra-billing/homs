module HBW
  class ProcessDefinition
    extend HBW::Remote
    include HBW::Definition

    class << self
      def fetch(url)
        new(do_request(:get, url))
      end
    end

    definition_reader :name, :deployment_id
  end
end
