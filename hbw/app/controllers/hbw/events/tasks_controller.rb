module HBW
  module Events
    class TasksController < BaseController
      def update
        event = {
          task_id:  params['id'],
          name:     params['event_name'],
          assignee: params['assignee'],
          version:  params['version'],
          users:    params['users'] || []
        }

        HBW::TaskNotifier.(widget: widget, event: event)

        head :ok
      end
    end
  end
end
