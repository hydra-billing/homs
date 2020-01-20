json.tasks do
  json.partial! partial: 'hbw/tasks/task', collection: @tasks, as: :task
end
