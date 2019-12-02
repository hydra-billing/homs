module HBW
  module WithDefinitions
    def with_definitions(entity_code_key)
      tasks = yield

      entity_codes = fetch_variable_for_processes(entity_code_key, tasks.map { |task| task.fetch('processInstanceId') })

      zip(tasks, process_definitions, entity_codes)
    end

    def process_definitions
      Rails.cache.fetch(:process_definitions) do
        do_request(:get, 'process-definition').map do |definition|
          ::HBW::ProcessDefinition.new(definition)
        end
      end
    end

    def zip(tasks, definitions, variables)
      tasks.map do |task|
        new(task.merge(
              'processDefinition' => fetch_definition(definitions, task.fetch('processDefinitionId')),
              'variables' => HBW::Variable.wrap(variables.select { |var| var.fetch('processInstanceId') == task.fetch('processInstanceId') })
            ))
      end
    end

    def fetch_definition(definitions, id)
      definition = definitions.find { |d| d.id == id }

      if definition.nil?
        Rails.cache.delete(:process_definitions)
        process_definitions.find { |d| d.id == id }
      else
        definition
      end
    end

    def fetch_variable_for_processes(name, process_ids)
      do_request(:post,
                 'variable-instance',
                 variableName: name,
                 processInstanceIdIn: process_ids.uniq)
    end
  end
end
