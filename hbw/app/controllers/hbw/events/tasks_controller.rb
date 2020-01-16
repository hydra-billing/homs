module HBW
  module Events
    class TasksController < BaseController
      def update
        HBW::TaskNotifier.(widget, params['id'], params['event_name'], params['users'])

        head :ok
      end
    end
  end
end
