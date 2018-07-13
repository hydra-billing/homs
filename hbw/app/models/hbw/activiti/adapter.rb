module HBW
  module Activiti
    # rubocop:disable Metrics/ClassLength
    class Adapter
      include HBW::Inject[:api, :config]

      def entity_code_key(entity_class)
        config.fetch(entity_class)[:entity_code_key]
      end

      # TODO: cache it until new user is added
      def users
        HBW::BPMUser.fetch_all
      end

      def user_exist?(user_email)
        user = HBW::BPMUser.with_connection(api) do
          HBW::BPMUser.fetch(user_email)
        end

        !user.nil?
      end

      def users_lookup(pattern)
        d_pattern = pattern.mb_chars.downcase.to_s
        users.select do |user|
          user.values.find { |v| v.mb_chars.downcase.include?(d_pattern) }
        end
      end

      def process_instances(entity_code, entity_class)
        response = api.post(
          '/rest/process-instance', variables: [
            name: entity_code_key(entity_class),
            value: entity_code,
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

      # TODO: How to distinguish between running process instance and done
      # TODO: Think of suspended process instances
      def bp_running?(entity_code, entity_class, current_user_identifier)
        !process_instances(entity_code, entity_class).empty? ||
            !task_list_response(current_user_identifier, entity_code, entity_class, 1000, true).empty?
      end

      def start_process(bp_code,
                        user_email,
                        entity_code,
                        entity_class)
        user = HBW::BPMUser.with_connection(api) do
          HBW::BPMUser.fetch(user_email)
        end
        return false unless user

        p_def = process_definition_for_key_like(bp_code)
        return false unless p_def

        variables = {
            :initiator                    => {value: user.id, type: :string},
            :initiatorEmail               => {value: user.email, type: :string},
            entity_code_key(entity_class) => {value: entity_code, type: :string}
        }

        response = start_process_response(p_def['id'], variables)
        response.status == 201
      end

      def drop_processes(entity_code, entity_class)
        ids = process_instances(entity_code, entity_class).map { |i| i['id'] }
        ids.map do |id|
          response = api.delete("runtime/process-instances/#{id}")
          response.status == 204
        end
        ids.reject { |e| e }.empty?
      end

      def entity_task_list(user_email, entity_code, entity_class, size = 1000)
        response = task_list_response(user_email, entity_code, entity_class, size)
        ::HBW::Task.wrap(response.body['data']) if response.status == 200
      end

      def task_list(email, entity_class, size = 1000)
        task_list_response(email, '%', entity_class, size)
      end

      def form(user_email, entity_class, task_id)
        task = task_for_email_and_task_id(user_email, entity_class, task_id)
        HBW::Form.with_connection(api) do
          HBW::Form.fetch(task, entity_class)
        end
      end

      def process_definition_for_key_like(key)
        response = api.get('/rest/process-definition', keyLike: key, latestVersion: true)
        response.body.first if response.status == 200
      end

      def start_process_response(id, variables)
        api.post("process-definition/#{id}/start",
                 variables: variables)
      end

      def task_list_response(email, entity_code, entity_class, size, for_all_users = false)
        HBW::Task.with_connection(api) do
          HBW::Task.fetch(email, entity_code, entity_class, size, for_all_users)
        end
      end

      def task_for_email_and_task_id(user_email, entity_class, task_id)
        task_list(user_email, entity_class).find { |task| task.id == task_id }
      end

      def process_instance_from(proc_inst_id)
        response = api.get("runtime/process-instances/#{proc_inst_id}")
        response.body if response.status == 200
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
