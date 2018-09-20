module HBW
  module Activiti
    class Adapter < ::HBW::Common::Adapter
      include HBW::Inject[:api, :config]

      def process_instances(entity_code, entity_class)
        response = api.post(
            'query/process-instances',
            variables: [
              name:      entity_code_key(entity_class),
              value:     entity_code,
              operation: :equals,
              type:      :string
            ])
        response.status == 200 && response.body['data'] || []
      end

      def submit(user_email, entity_class, task_id, form_data)
        form_definition = form(user_email, entity_class, task_id)

        variables = form_definition.extract_and_coerce_values(form_data).map do |key, value|
          { name: key, value: value }
        end
        response = api.post("runtime/tasks/#{task_id}", action: :complete, variables: variables)
        response.status == 200
      end

      def get_variables(user, entity_class, entity_code)
        [
          { name: :initiator,                    value: user.id,     type: :string },
          { name: :initiatorEmail,               value: user.email,  type: :string },
          { name: entity_code_key(entity_class), value: entity_code, type: :string }
        ]
      end

      def process_definition_for_key_like(key)
        response = api.get('repository/process-definitions', keyLike: key, latest: true)
        response.body['data'].first if response.status == 200
      end

      def start_process_response(id, variables)
        api.post('runtime/process-instances',
                 processDefinitionId: id,
                 variables: variables)
      end
    end
  end
end
