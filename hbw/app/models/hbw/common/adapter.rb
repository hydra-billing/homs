module HBW
  module Common
    class Adapter
      include Dry::Monads[:do, :list, :result, :task]

      include Dry::Effects::Handler.Reader(:connection)
      include HBW::Inject[:api, :config]
      include HBW::WithDefinitions
      include HBW::UserHelper

      def entity_code_key(entity_class)
        config[:entities].fetch(entity_class)[:entity_code_key]
      end

      def user_exists?(user_email)
        users = fetch_concurrently do
          HBW::BPMUser.fetch(user_email)
        end

        users.length == api.length
      end

      def definitions_with_starter_candidates(user_email)
        fetch_concurrently do
          with_user(user_email) do |user|
            process_definitions_with_starter_candidates(user.id)
          end
        end
      end

      def users_lookup(pattern)
        d_pattern = pattern.mb_chars.downcase.to_s

        users.select do |user|
          user.values.find { |v| v.mb_chars.downcase.include?(d_pattern) }
        end
      end

      def active_process_instances(_, _)
        raise NotImplementedError
      end

      def submit(_, _, _, _)
        raise NotImplementedError
      end

      # TODO: How to distinguish between running process instance and done
      # TODO: Think of suspended process instances
      def bp_running?(entity_code, entity_class, bp_codes)
        processes = active_process_instances(entity_code, entity_class)
        definitions = fetch_concurrently { process_definitions }

        definitions_ids = definitions.select { |d| bp_codes.include?(d.key) }.map(&:id)

        processes.select { |p| p['definitionId'].in?(definitions_ids) }.present?
      end

      def get_variables(_, _, _, _)
        raise NotImplementedError
      end

      def start_process(bp_code,
                        user_email,
                        entity_code,
                        entity_class,
                        initial_variables)
        user = with_connection(api_by_process_key(bp_code)) do
          HBW::BPMUser.fetch(user_email)
        end
        return false unless user

        p_def = process_definition_for_key_like(bp_code)
        return false unless p_def

        variables = get_variables(user, entity_class, entity_code, initial_variables)

        entity_type = HBW::Widget.config[:entities].fetch(entity_class.to_sym)[:bp_toolbar][:entity_type_buttons].select do |_key, value|
                        value.any? do |bp|
                          bp[:bp_code] == bp_code
                        end
                      end.keys[0]

        business_key = [entity_class, entity_type, entity_code].join('_')

        response = start_process_response(p_def['id'], variables, business_key, bp_code)
        response['id'].present?
      end

      def api_by_process_key(process_key)
        api.find { |a| a.process_supported?(process_key) }
      end

      def fetch_concurrently(&block)
        result = List[*api].typed(Dry::Monads::Task).traverse do |c|
          Dry::Monads::Task[:io] do
            with_connection(c, &block)
          end
        end.to_result

        if result.success?
          result.value!.to_a.flatten
        else
          raise result.failure
        end
      end

      def task_list(email, entity_class)
        fetch_concurrently do
          HBW::Task.list(email, entity_class)
        end
      end

      def claim_task(email, task_id, process_key)
        with_connection(api_by_process_key(process_key)) do
          HBW::Task.claim_task(email, task_id)
        end
      end

      def form(task_id, entity_class, process_key)
        with_connection(api_by_process_key(process_key)) do
          HBW::Form.fetch(task_id, entity_class)
        end
      end

      def get_forms_for_task_list(tasks)
        JSON.parse(tasks).map do |task|
          {
            form_fields: form(task['task_id'], task['entity_class'], task['process_key']),
            task_id:     task['task_id']
          }
        end
      end

      def get_form_by_task_id(task_id, process_key)
        with_connection(api_by_process_key(process_key)) do
          HBW::Form.get_form_by_task_id(task_id)
        end
      end

      def get_task_by_id(task_id, process_key)
        with_connection(api_by_process_key(process_key)) do
          HBW::Task.get_task_by_id(task_id)
        end
      end

      def get_task_with_form(task_id, entity_class, cache_key, process_key)
        with_connection(api_by_process_key(process_key)) do
          HBW::Task.get_task_with_form(task_id, entity_class, cache_key)
        end
      end
    end
  end
end
