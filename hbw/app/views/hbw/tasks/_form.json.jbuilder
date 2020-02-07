json.set! :css_class, form[:form_fields].css_class
json.set! :fields, form[:form_fields].fields.map(&:as_json)
json.set! :variables, form[:form_fields].variables
json.set! :csrf_token, csrf_token
json.set! :task_id, form[:task_id]
