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
        unless user.nil?
          wrap(
            do_request(:post,
                       'task',
                       assignee:   assignee(user, email, for_all_users),
                       active:     true,
                       processVariables: [
                         name:     HBW::Widget.config.fetch(entity_class)[:entity_code_key],
                         operator: operation(entity_code),
                         value:    entity_code
                       ],
                       maxResults: size))
        end
      end

      def wrap(tasks)
        definitions = tasks.map.with_object({}) do |task, d|
          id = task.fetch('processDefinitionId')

          variables = do_request(:get, "process-instance/#{task.fetch('processInstanceId')}/variables")
          task.merge!('variables' => variables.map { |k, v| v.merge({ 'name' => k })})

          url = "process-definition/#{id}"

          d[url] ||= ::HBW::ProcessDefinition.fetch(url)
        end
        tasks.map { |task|
          new(task.merge('processDefinition' => definitions["process-definition/#{task.fetch('processDefinitionId')}"]))
        }
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
      variable(config.fetch(entity_class)[:entity_code_key]).value
    end
  end
end
