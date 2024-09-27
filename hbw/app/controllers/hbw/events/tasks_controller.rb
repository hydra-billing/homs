module HBW
  module Events
    class TasksController < APIController
      def update
        event = {
          task_id:     params['id'],
          name:        params['event_name'],
          assignee:    params['assignee'],
          version:     params['version'],
          users:       params['users'] || [],
          process_key: params['process_key']
        }

        HBW::TaskNotifier.(widget:, event:)

        head :ok
      end
    end
  end
end
