json.task_count @task_count

json.tasks do
  json.partial! partial: 'hbw/tasks/task', collection: @tasks, as: :task
end
