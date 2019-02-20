module HBW
  class Deployment
    extend HBW::Remote
    include HBW::Definition
    include HBW::Inject[:config]

    class << self
      def fetch(process_definition)
        deployment_id = process_definition.deployment_id
        resources = do_request(:get, "#{deployments_url_prefix}/%s/resources" % deployment_id)
        new(do_request(:get, "#{deployments_url_prefix}/%s" % deployment_id).merge(
          'resources' => resources
        ))
      end

      def deployments_url_prefix
        'deployment'
      end
    end

    definition_reader :resources

    def resource(resource_id)
      resources.find do |resource|
        resource[resource_key] == resource_id
      end
    end

    def resource_key
      'name'
    end
  end
end
