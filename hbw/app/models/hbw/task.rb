module HBW
  class Task
    extend HBW::Remote
    extend HBW::WithDefinitions
    extend HBW::TaskHelper
    include HBW::GetIcon
    include HBW::Definition

    attr_accessor :form

    def method_missing(variable_name)
      if variable(variable_name.to_s).blank?
        raise I18n.t('config.bad_entity_url', variable_name: variable_name)
      end

      variable(variable_name.to_s).value
    end

    class << self
      def with_user(email)
        user = ::HBW::BPMUser.fetch(email)

        unless user.nil?
          yield(user)
        end
      end

      def get_task_by_id(id)
        do_request(:get, "task/#{id}")
      end

      def get_task_with_form(id, entity_class, cache_key)
        entity_code_variable_name = entity_code_key(entity_class)

        if cache_key && Rails.cache.exist?(cache_key)
          cache = Rails.cache.read(cache_key)

          task = with_cached_definition(cache[:task], entity_code_variable_name, cache_key)
          task.form = cache[:form]
        else
          task = with_definition(get_task_by_id(id), entity_code_variable_name)
          task.form = Form.fetch(id, entity_class)
        end

        task
      end

      def update_description(id, description)
        do_request(:put,
                   "task/#{id}",
                   description: description)
      end

      def list(email, entity_class)
        entity_code_variable_name = entity_code_key(entity_class)

        with_user(email) do |user|
          with_definitions(entity_code_variable_name) do
            options = {
                active:  true,
                processVariables: [
                  name:     entity_code_variable_name,
                  operator: :like,
                  value:    '%'
                ]
            }

            do_request(:post, 'task', **options.merge(assignee: user.id)) +
              do_request(:post, 'task', **options.merge(candidateUser: user.id))
          end
        end
      end

      def claim_task(email, task_id)
        with_user(email) do |user|
          do_request(:post,
                     "task/#{task_id}/claim",
                     userId: user.id)
        end
      end

      def sorting_fields(entity_class)
        [
          {
            sortBy:    'dueDate',
            sortOrder: 'asc'
          },
          {
            sortBy:    'priority',
            sortOrder: 'desc'
          },
          {
            sortBy:    'processVariable',
            sortOrder: 'asc',
            parameters: {
              variable: bp_name_key(entity_class),
              type:     'String'
            }
          },
          {
            sortBy:    'created',
            sortOrder: 'asc'
          }
        ]
      end
    end

    definition_reader :id, :name, :description, :process_instance_id,
                      :process_definition_id, :process_name, :form_key,
                      :assignee, :priority, :created, :due, :variables

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
