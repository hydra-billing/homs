module HBW
  module WithDefinitions
    def with_definitions(entity_code_key)
      tasks = yield

      definitions = build_definitions(tasks)

      entity_codes = fetch_variable_for_processes(entity_code_key, tasks.map { |task| task.fetch('processInstanceId') })

      zip(tasks, definitions, entity_codes)
    end

    def build_definitions(tasks)
      do_request(:get,
                 'process-definition',
                 processDefinitionIdIn: tasks.map { |task| task.fetch('processDefinitionId') })
    end

    def zip(tasks, definitions, variables)
      tasks.map do |task|
        new(task.merge(
              'processDefinition' => ::HBW::ProcessDefinition.new(definitions.find { |d| d['id'] == task.fetch('processDefinitionId') }),
              'variables' => variables.select { |var| var.fetch('processInstanceId') == task.fetch('processInstanceId') }
            ))
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
