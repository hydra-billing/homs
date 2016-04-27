json.group_by_var widget.config[:task_list].try(:group_by_var)

json.tasks do
  json.partial! partial: 'hbw/tasks/task', collection: @tasks, as: :task
end
