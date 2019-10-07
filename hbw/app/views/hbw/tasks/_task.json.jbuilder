json.set! :id, task.id
json.set! :name, task.name
json.set! :priority, task.priority
json.set! :icon, task.get_icon(params[:entity_class])
json.set! :assignee, task.assignee
json.set! :description, task.description
json.set! :created, task.created
json.set! :entity_code, task.entity_code(params[:entity_class].to_sym)
json.set! :process_instance_id, task.process_instance_id
json.set! :variables, task.variables.map(&:to_h)
json.set! :process_name, task.process_name
json.set! :entity_url, entity_url(task, params[:entity_class].to_sym)
