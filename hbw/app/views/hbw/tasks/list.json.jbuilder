json.tasks do
  json.partial! partial: 'hbw/tasks/claiming_task', collection: @tasks, as: :task
end
