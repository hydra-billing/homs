module HBW
  module Camunda
    class Adapter < ::HBW::Common::Adapter
      include HBW::Inject[:api, :config]

      def process_instances(entity_code, entity_class)
        response = api.post(
            '/rest/process-instance',
            variables: [
              name:     entity_code_key(entity_class),
              value:    entity_code,
              operator: :eq
            ])
        response.status == 200 && response.body || []
      end


      def submit(user_email, entity_class, task_id, form_data)
        form_definition = form(user_email, entity_class, task_id)

        variables = form_definition.extract_and_coerce_values(form_data).map do |key, value|
          { name: key, value: value }
        end

        variables = variables.map { |item| [item.delete(:name), item]}.to_h

        response = api.post("/rest/task/#{task_id}/submit-form", variables: variables)
        response.status == 204
      end

      def get_variables(user, entity_class, entity_code)
        [
          { name: :initiator,                    value: user.id,     type: :string },
          { name: :initiatorEmail,               value: user.email,  type: :string },
          { name: entity_code_key(entity_class), value: entity_code, type: :string }
        ]
      end

      def process_definition_for_key_like(key)
        response = api.get('/rest/process-definition', keyLike: key, latestVersion: true)
        response.body.first if response.status == 200
      end

      def start_process_response(id, variables)
        api.post("process-definition/#{id}/start",
                 variables: variables)
      end
    end
  end
end
