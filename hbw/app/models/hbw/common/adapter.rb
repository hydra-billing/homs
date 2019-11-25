module HBW
  module Common
    class Adapter
      include HBW::Inject[:api, :config]

      def entity_code_key(entity_class)
        config[:entities].fetch(entity_class)[:entity_code_key]
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

      def process_instances(_, _)
        raise NotImplementedError
      end

      def submit(_, _, _, _)
        raise NotImplementedError
      end

      # TODO: How to distinguish between running process instance and done
      # TODO: Think of suspended process instances
      def bp_running?(entity_code, entity_class, current_user_identifier)
        !process_instances(entity_code, entity_class).empty? ||
          !task_list_wrapped(current_user_identifier, entity_code, entity_class, 1000, true).empty?
      end

      def get_variables(_, _, _, _)
        raise NotImplementedError
      end

      def start_process(bp_code,
                        user_email,
                        entity_code,
                        entity_class,
                        initial_variables)
        user = HBW::BPMUser.with_connection(api) do
          HBW::BPMUser.fetch(user_email)
        end
        return false unless user

        p_def = process_definition_for_key_like(bp_code)
        return false unless p_def

        variables = get_variables(user, entity_class, entity_code, initial_variables)

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
        task_list_wrapped(user_email, entity_code, entity_class, size)
      end

      def task_list(email, entity_class, size = 1000)
        task_list_wrapped(email, '%', entity_class, size)
      end

      def claiming_task_list(email, entity_class, assigned, max_results, search_query)
        HBW::Task.with_connection(api) do
          HBW::Task.fetch_for_claiming(email, entity_class, assigned, max_results, search_query)
        end
      end

      def task_count(email, entity_class)
        HBW::Task.with_connection(api) do
          HBW::Task.fetch_count(email, entity_class)
        end
      end

      def task_count_unassigned(email, entity_class)
        HBW::Task.with_connection(api) do
          HBW::Task.fetch_count_unassigned(email, entity_class)
        end
      end

      def claim_task(email, task_id)
        HBW::Task.with_connection(api) do
          HBW::Task.claim_task(email, task_id)
        end
      end

      def form(user_email, entity_class, task_id)
        task = task_for_email_and_task_id(user_email, entity_class, task_id)
        HBW::Form.with_connection(api) do
          HBW::Form.fetch(task, entity_class)
        end
      end

      def task_list_wrapped(email, entity_code, entity_class, size, for_all_users = false)
        HBW::Task.with_connection(api) do
          HBW::Task.fetch(email, entity_code, entity_class, size, for_all_users) +
            HBW::Task.fetch_unassigned(email, entity_class, 0, 1000)
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
  end
end
