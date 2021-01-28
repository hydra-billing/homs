module HBW
  module Camunda
    class Adapter < ::HBW::Common::Adapter
      include HBW::Inject[:api, :config]

      def active_process_instances(entity_code, entity_class)
        response = api.post(
          'process-instance',
          active:    true,
          variables: [
            name:     entity_code_key(entity_class),
            value:    entity_code,
            operator: :eq
          ]
        )

        response.status == 200 && response.body || []
      end

      def cancel_process(id)
        response = api.delete("process-instance/#{id}")
        response.status == 204
      end

      def submit(entity_class, task_id, form_data)
        form_definition = form(task_id, entity_class)

        variables = form_definition.extract_and_coerce_values(form_data).map do |key, value|
          {name: key, value: value}
        end

        variables = variables.map { |item| [item.delete(:name), item] }.to_h

        response = api.post("task/#{task_id}/submit-form", variables: variables)

        response.status == (Rails.env.test? ? 200 : 204)
      end

      def get_variables(user, entity_class, entity_code, initial_variables)
        {
          :initiator                    => {value: user.id,     type: :string},
          :initiatorEmail               => {value: user.email,  type: :string},
          entity_code_key(entity_class) => {value: entity_code, type: :string}
        }.merge(initial_variables)
      end

      def process_definition_for_key_like(key)
        response = api.get('process-definition', keyLike: key, latestVersion: true)
        response.body.first if response.status == 200
      end

      def start_process_response(id, variables)
        api.post("process-definition/#{id}/start",
                 variables: variables)
      end
    end
  end
end
