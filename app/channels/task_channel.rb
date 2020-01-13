class TaskChannel < ApplicationCable::Channel
  def subscribed
    stream_from "task_channel_#{current_user.email}"
  end
end
