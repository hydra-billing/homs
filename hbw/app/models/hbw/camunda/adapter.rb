module HBW
  module Camunda
    class Adapter < ::HBW::Common::Adapter
      include HBW::Remote
      include HBW::Inject[:api, :config]

      def active_process_instances(entity_code, entity_class)
        fetch_concurrently do
          do_request(
            :post,
            'process-instance',
            active:    true,
            variables: [
              name:     entity_code_key(entity_class),
              value:    entity_code,
              operator: :eq
            ]
          )
        end
      end

      def cancel_process(id, process_key)
        with_connection(api_by_process_key(process_key)) do
          do_request(:delete, "process-instance/#{id}")
        end
      end

      def submit(entity_class, task_id, form_data, process_key)
        form_definition = form(task_id, entity_class, process_key)

        variables = form_definition.extract_and_coerce_values(form_data).map do |key, value|
          {name: key, value: value}
        end

        variables = variables.to_h { |item| [item.delete(:name), item] }

        with_connection(api_by_process_key(process_key)) do
          do_request(:post, "task/#{task_id}/submit-form", variables: variables)
        end
      end

      def get_variables(user, entity_class, entity_code, initial_variables)
        {
          :initiator                    => {value: user.id,     type: :string},
          :initiatorEmail               => {value: user.email,  type: :string},
          entity_code_key(entity_class) => {value: entity_code, type: :string}
        }.merge(initial_variables)
      end

      def process_definition_for_key_like(key)
        with_connection(api_by_process_key(key)) do
          do_request(:get, 'process-definition', keyLike: key, latestVersion: true).first
        end
      end

      def start_process_response(id, variables, business_key, process_key)
        with_connection(api_by_process_key(process_key)) do
          do_request(:post, "process-definition/#{id}/start",
                     businessKey: business_key,
                     variables:   variables)
        end
      end
    end
  end
end
