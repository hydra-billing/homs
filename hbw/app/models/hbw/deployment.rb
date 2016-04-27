module HBW
  class Deployment
    extend HBW::Remote
    include HBW::Definition

    class << self
      using_connection \
      def fetch(process_definition)
        deployment_id = process_definition.deployment_id
        resources = do_request(:get, 'repository/deployments/%s/resources' % deployment_id)
        new(do_request(:get, 'repository/deployments/%s' % deployment_id).merge(
          'resources' => resources
        ))
      end
    end

    definition_reader :resources

    def resource(resource_id)
      resources.find do |resource|
        resource['id'] == resource_id
      end
    end
  end
end
