json.tasks do
  json.partial! partial: 'hbw/tasks/task_without_form', collection: @tasks, as: :task
end
