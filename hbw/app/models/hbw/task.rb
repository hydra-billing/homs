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
      using_connection \
      def fetch(email, entity_code, size = 1000)
        user = ::HBW::BPMUser.fetch(email)
        operation = entity_code == '%' ? :like : :equals
        wrap(
          do_request(:post,
                     'query/tasks',
                     assignee: user.try(:id) || email,
                     active: true,
                     includeProcessVariables: true,
                     processInstanceVariables: [
                       name: HBW::Widget.config['entity_code_key'],
                       operation: operation,
                       value: entity_code
                     ],
                     size: size))
      end

      def wrap(tasks)
        definitions = tasks.map.with_object({}) do |task, d|
          url = task.fetch('processDefinitionUrl')
          d[url] ||= ::HBW::ProcessDefinition.fetch(url)
        end
        tasks.map { |task|
          new(task.merge('processDefinition' => definitions[task.fetch('processDefinitionUrl')])) }
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

    def entity_code
      variable(config[:entity_code_key]).value
    end
  end
end
