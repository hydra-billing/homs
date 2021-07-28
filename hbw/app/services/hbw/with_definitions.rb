module HBW
  module WithDefinitions
    def with_definitions(entity_code_key)
      tasks = yield

      entity_codes = fetch_variable_for_processes(entity_code_key, tasks.map { |task| task.fetch('processInstanceId') })

      zip_many(tasks, process_definitions, entity_codes)
    end

    def with_definition(task, entity_code_key)
      entity_code = fetch_variable_for_process(entity_code_key, task.fetch('processInstanceId'))

      zip_one(task, process_definitions, entity_code)
    end

    def with_cached_definition(task, entity_code_key, cache_key)
      entity_code = fetch_cached_variable(entity_code_key, cache_key)

      zip_one(task, process_definitions, entity_code)
    end

    def process_definitions
      Rails.cache.fetch(:process_definitions) do
        do_request(:get, 'process-definition').map do |definition|
          ::HBW::ProcessDefinition.new(definition)
        end
      end
    end

    def zip_one(task, definitions, variable)
      new(task.merge(
            'processDefinition' => fetch_definition(definitions, task.fetch('processDefinitionId')),
            'variables'         => [HBW::Variable.new(variable)]
          ))
    end

    def zip_many(tasks, definitions, variables)
      tasks.map do |task|
        new(task.merge(
              'processDefinition' => fetch_definition(definitions, task.fetch('processDefinitionId')),
              'variables'         => HBW::Variable.wrap(variables.select { |var| var.fetch('processInstanceId') == task.fetch('processInstanceId') })
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
                 variableName:        name,
                 processInstanceIdIn: process_ids.uniq)
    end

    def fetch_variable_for_process(name, process_id)
      do_request(:get,
                 'variable-instance',
                 variableName:        name,
                 processInstanceIdIn: process_id).first
    end

    def fetch_cached_variable(name, cache_key)
      Rails.cache
           .read(cache_key)[:form]
           .variables
           .find { |var| var.fetch('name') == name }
    end
  end
end
