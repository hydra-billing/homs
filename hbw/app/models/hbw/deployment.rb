module HBW
  class Deployment
    extend HBW::Remote
    include HBW::Definition

    class << self
      def fetch(process_definition)
        deployment_id = process_definition.deployment_id
        resources = do_request(:get, '/rest/deployment/%s/resources' % deployment_id)
        new(do_request(:get, '/rest/deployment/%s' % deployment_id).merge(
          'resources' => resources
        ))
      end
    end

    definition_reader :resources

    def resource(resource_id)
      resources.find do |resource|
        resource['name'] == resource_id
      end
    end
  end
end
