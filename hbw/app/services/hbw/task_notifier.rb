module HBW
  class TaskNotifier
    class << self
      def call(widget, task_id, event_name, assignee, users = [])
        message = {
          task_id: task_id,
          event_name: event_name
        }

        if need_to_fetch_task?(event_name)
          timestamp = (Time.now.to_f * 1000).to_i
          cache_key = "#{task_id}_#{timestamp}_#{SecureRandom.hex(10)}"

          Rails.cache.fetch(cache_key, expires_in: 300) do
            {
              task: widget.get_task_by_id(task_id),
              form: widget.get_form_by_task_id(task_id)
            }
          end

          message[:cache_key] = cache_key
        end

        users.each do |user|
          message[:assigned_to_me] = event_name == 'assignment' && user == assignee

          ActionCable.server.broadcast("task_channel_#{user}", message.to_json)
        end
      end

      private

      def need_to_fetch_task?(event_name)
        %w(create assignment).include?(event_name)
      end
    end
  end
end
