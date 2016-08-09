module HBW
  module Activiti
    # rubocop:disable Metrics/ClassLength
    class Adapter
      include HBW.inject[:activiti_api]

      attr_accessor :api, :entity_code_key

      def initialize(entity_code_key: , activiti_api: )
        @entity_code_key = entity_code_key
        @api = activiti_api
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

      def process_instances(entity_code)
        response = api.post(
          'query/process-instances', variables: [{
            name: entity_code_key,
            value: entity_code,
            operation: :equals,
            type: :string
          }])
        response.status == 200 && response.body['data'] || []
      end

      def submit(user_email, task_id, form_data)
        form_definition = form(user_email, task_id)

        variables = form_definition.extract_and_coerce_values(form_data).map do |key, value|
          { name: key, value: value }
        end
        response = api.post("runtime/tasks/#{task_id}", action: :complete, variables: variables)
        response.status == 200
      end

      # TODO: How to distinguish between running process instance and done
      # TODO: Think of suspended process instances
      def bp_running?(entity_code)
        !process_instances(entity_code).empty?
      end

      def start_process(bp_code,
                        user_email,
                        entity_code)
        user = HBW::BPMUser.with_connection(api) do
          HBW::BPMUser.fetch(user_email)
        end
        return false unless user

        p_def = process_definition_for_key_like(bp_code)
        return false unless p_def

        variables = [
          { name: :initiator,      value: user.id,     type: :string },
          { name: :initiatorEmail, value: user.email,  type: :string },
          { name: entity_code_key, value: entity_code, type: :string }
        ]

        response = start_process_response(p_def['id'], variables)
        response.status == 201
      end

      def drop_processes(entity_code)
        ids = process_instances(entity_code).map { |i| i['id'] }
        ids.map do |id|
          response = api.delete("runtime/process-instances/#{id}")
          response.status == 204
        end
        ids.reject { |e| e }.empty?
      end

      def entity_task_list(user_email, entity_code, size = 1000)
        response = task_list_response(user_email, entity_code, size)
        ::HBW::Task.wrap(response.body['data']) if response.status == 200
      end

      def task_list(email, size = 1000)
        task_list_response(email, '%', size)
      end

      def form(user_email, task_id)
        task = task_for_email_and_task_id(user_email, task_id)
        HBW::Form.with_connection(api) do
          HBW::Form.fetch(task)
        end
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

      def task_list_response(email, entity_code, size)
        HBW::Task.with_connection(api) do
          HBW::Task.fetch(email, entity_code, size)
        end
      end

      def task_for_email_and_task_id(user_email, task_id)
        task_list(user_email).find { |task| task.id == task_id }
      end

      def process_instance_from(proc_inst_id)
        response = api.get("runtime/process-instances/#{proc_inst_id}")
        response.body if response.status == 200
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
