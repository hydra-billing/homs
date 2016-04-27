json.tasks do
  json.partial! partial: 'tasks/task', collection: @tasks, as: :task
end
