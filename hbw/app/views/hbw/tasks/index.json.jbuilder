json.group_by_var widget.config[:entities].fetch(params[:entity_class].to_sym)[:task_list].try(:group_by_var)
json.task_count @task_count

json.tasks do
  json.partial! partial: 'hbw/tasks/task', collection: @tasks, as: :task
end
