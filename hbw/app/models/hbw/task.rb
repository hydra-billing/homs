module HBW
  class Task
    extend HBW::Remote
    extend HBW::WithDefinitions
    include HBW::GetIcon
    include HBW::Definition

    def method_missing(variable_name)
      if self.variable(variable_name.to_s).blank?
        raise I18n.t('config.bad_entity_url', variable_name: variable_name)
      end

      self.variable(variable_name.to_s).value
    end

    class << self
      def with_user(email)
        user = ::HBW::BPMUser.fetch(email)

        unless user.nil?
          yield(user)
        end
      end

      def fetch(email, entity_code, entity_class, size = 1000, for_all_users = false)
        entity_code_key = HBW::Widget.config[:entities].fetch(entity_class)[:entity_code_key]

        with_user(email) do |user|
          with_definitions(entity_code_key) do
            do_request(:post,
                       'task',
                       assignee:   assignee(user, email, for_all_users),
                       active:     true,
                       processVariables: [
                         name:     entity_code_key,
                         operator: operation(entity_code),
                         value:    entity_code
                       ],
                       maxResults: size)
          end
        end
      end

      def fetch_count(email)
        with_user(email) do |user|
          do_request(:post,
                     'task/count',
                     assignee: user.id,
                     active:   true)['count']
        end
      end

      def fetch_count_unassigned(email)
        with_user(email) do |user|
          do_request(:post,
                     'task/count',
                     candidateUser: user.id,
                     active:        true)['count']
        end
      end

      def update_description(id, description)
        do_request(:put,
                   "task/#{id}",
                   description: description)
      end

      def fetch_for_claiming(email, entity_class, assigned, max_results, search_query)
        entity_code_key = HBW::Widget.config[:entities].fetch(entity_class)[:entity_code_key]
        bp_name_key = HBW::Widget.config[:entities].fetch(entity_class)[:bp_name_key]

        with_user(email) do |user|
          with_definitions(entity_code_key) do
            options = {
                active:  true,
                sorting: sorting_fields(bp_name_key)
            }

            if assigned
              options.merge!(assignee: user.id)
            else
              options.merge!(candidateUser: user.id)
            end

            if search_query.present?
              options.merge!(descriptionLike: "%#{search_query}%")
            end

            do_request(:post, "task?maxResults=#{max_results}", **options)
          end
        end
      end

      def fetch_unassigned(email, entity_class, first_result, max_results)
        entity_code_key = HBW::Widget.config[:entities].fetch(entity_class)[:entity_code_key]
        bp_name_key = HBW::Widget.config[:entities].fetch(entity_class)[:bp_name_key]

        with_user(email) do |user|
          with_definitions(entity_code_key) do
            do_request(:post,
                       "task?firstResult=#{first_result}&maxResults=#{max_results}",
                       active:        true,
                       candidateUser: user.id,
                       sorting:       sorting_fields(bp_name_key))
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

      def sorting_fields(bp_name_key)
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
              variable: bp_name_key,
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
                      :assignee, :priority, :created, :due

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
