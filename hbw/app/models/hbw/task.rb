module HBW
  class Task
    extend HBW::Remote
    include HBW::Definition

    def method_missing(variable_name)
      if self.variable(variable_name.to_s).blank?
        raise I18n.t('config.bad_entity_url', variable_name: variable_name)
      end

      self.variable(variable_name.to_s).value
    end

    class << self
      def fetch(email, entity_code, entity_class, size = 1000, for_all_users = false)
        user = ::HBW::BPMUser.fetch(email)
        entity_code_key = HBW::Widget.config[:entities].fetch(entity_class)[:entity_code_key]

        unless user.nil?
          tasks = do_request(:post,
                             'task',
                             assignee:   assignee(user, email, for_all_users),
                             active:     true,
                             processVariables: [
                               name:     entity_code_key,
                               operator: operation(entity_code),
                               value:    entity_code
                             ],
                             maxResults: size)

          definitions = build_definitions(tasks)

          entity_codes = fetch_variable_for_processes(entity_code_key, tasks.map { |task| task.fetch('processInstanceId') })

          zip(tasks, definitions, entity_codes)
        end
      end

      def fetch_task_count(email, entity_code, entity_class, for_all_users = false)
        user = ::HBW::BPMUser.fetch(email)
        unless user.nil?
          do_request(:post,
                     'task/count',
                     assignee:   assignee(user, email, for_all_users),
                     active:     true,
                     processVariables: [
                       name:     HBW::Widget.config[:entities].fetch(entity_class)[:entity_code_key],
                       operator: operation(entity_code),
                       value:    entity_code
                     ])['count']
        end
      end

      def fetch_unassigned_tasks(email, first_result, max_results)
        user = ::HBW::BPMUser.fetch(email)

        unless user.nil?
          do_request(:post,
                     "task?firstResult=#{first_result}&maxResults=#{max_results}",
                     active:         true,
                     unassigned:     true,
                     candidateUser:  user.id,
                     sorting: [
                       {
                         sortBy:    'dueDate',
                         sortOrder: 'asc'
                       },
                       {
                         sortBy:    'priority',
                         sortOrder: 'desc'
                       },
                       {
                         sortBy:    'name',
                         sortOrder: 'asc'
                       },
                       {
                         sortBy:    'created',
                         sortOrder: 'asc'
                       }
                     ])
        end
      end

      def build_definitions(tasks)
        tasks.map.with_object({}) do |task, d|
          url = "process-definition/#{task.fetch('processDefinitionId')}"

          d[url] ||= ::HBW::ProcessDefinition.fetch(url)
        end
      end

      def zip(tasks, definitions, variables)
        tasks.map do |task|
          new(task.merge(
                'processDefinition' => definitions["process-definition/#{task.fetch('processDefinitionId')}"],
                'variables' => variables.select { |var| var.fetch('processInstanceId') == task.fetch('processInstanceId') }
              ))
        end
      end

      def fetch_variable_for_processes(name, process_ids)
        do_request(:get, 'variable-instance',
                   variableName: name,
                   processInstanceIdIn: process_ids)
      end

      def assignee(user, email, for_all_users)
        unless for_all_users
          user.try(:id) || email
        end
      end

      def operation(entity_code)
        if entity_code == '%'
          :like
        else
          :eq
        end
      end
    end

    definition_reader :id, :name, :description, :process_instance_id,
                      :process_definition_id, :process_name, :form_key

    def variables
      @variables ||= Variable.wrap(definition['variables'])
    end

    def variables_hash
      variables.map.with_object({}) do |variable, h|
        h[variable.name.to_sym] = variable.value
      end
    end

    def variable(name)
      variables.find { |variable| variable.name == name }
    end

    def process_name
      process_definition.name
    end

    def process_definition
      @definition.fetch('processDefinition')
    end

    def entity_code(entity_class)
      variable(config[:entities].fetch(entity_class)[:entity_code_key]).value
    end
  end
end
