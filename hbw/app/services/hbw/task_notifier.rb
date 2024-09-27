module HBW
  class TaskNotifier
    class << self
      def call(widget:, event:)
        message = {
          task_id:     event[:task_id],
          event_name:  event[:name],
          version:     event[:version],
          process_key: event[:process_key]
        }

        if need_to_fetch_task?(event[:name])
          timestamp = (Time.now.to_f * 1000).to_i
          cache_key = "#{event[:task_id]}_#{timestamp}_#{SecureRandom.hex(10)}"

          Rails.cache.fetch(cache_key, expires_in: 300) do
            {
              task: widget.get_task_by_id(event[:task_id], event[:process_key]),
              form: widget.get_form_by_task_id(event[:task_id], event[:process_key])
            }
          end

          message[:cache_key] = cache_key
        end

        event[:users].each do |user|
          message[:assigned_to_me] = user == event[:assignee]

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
