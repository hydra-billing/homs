module HBW
  module Events
    class TasksController < ApiController
      def update
        event = {
          task_id:     params['id'],
          name:        params['event_name'],
          assignee:    params['assignee'],
          version:     params['version'],
          users:       params['users'] || [],
          process_key: params['process_key']
        }

        HBW::TaskNotifier.(widget: widget, event: event)

        head :ok
      end
    end
  end
end
