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

      def fetch(email, entity_code, entity_class, size = 1000)
        entity_code_variable_name = entity_code_key(entity_class)

        with_user(email) do |user|
          with_definitions(entity_code_variable_name) do
            do_request(:post,
                       'task',
                       assignee: user.id,
                       active:   true,
                       processVariables: [
                         name:     entity_code_variable_name,
                         operator: :eq,
                         value:    entity_code
                       ],
                       maxResults: size) +
              do_request(:post,
                         'task',
                         candidateUser: user.id,
                         active:     true,
                         processVariables: [
                           name:     entity_code_variable_name,
                           operator: :eq,
                           value:    entity_code
                         ],
                         maxResults: size)
          end
        end
      end

      def fetch_count(email, entity_class)
        with_user(email) do |user|
          do_request(:post,
                     'task/count',
                     assignee: user.id,
                     active:   true,
                     processVariables: [
                       name:     entity_code_key(entity_class),
                       operator: :like,
                       value:    '%'
                     ])['count']
        end
      end

      def fetch_count_unassigned(email, entity_class)
        with_user(email) do |user|
          do_request(:post,
                     'task/count',
                     candidateUser: user.id,
                     active:        true,
                     processVariables: [
                       name:     entity_code_key(entity_class),
                       operator: :like,
                       value:    '%'
                     ])['count']
        end
      end

      def update_description(id, description)
        do_request(:put,
                   "task/#{id}",
                   description: description)
      end

      def fetch_for_claiming(email, entity_class, assigned, max_results, search_query)
        entity_code_variable_name = entity_code_key(entity_class)

        with_user(email) do |user|
          with_definitions(entity_code_variable_name) do
            options = {
                active:  true,
                sorting: sorting_fields(entity_class),
                processVariables: [
                  name:     entity_code_variable_name,
                  operator: :like,
                  value:    '%'
                ]
            }

            if assigned
              options[:assignee] = user.id
            else
              options[:candidateUser] = user.id
            end

            if search_query.present?
              options[:descriptionLike] = "%#{search_query}%"
            end

            do_request(:post, "task?maxResults=#{max_results}", **options)
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
