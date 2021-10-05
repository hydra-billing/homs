json.ignore_nil!
json.set! :css_class, form[:form_fields].css_class
json.set! :hide_cancel_button, form[:form_fields].hide_cancel_button
json.set! :submit_button_name, form[:form_fields].submit_button_name
json.set! :cancel_button_name, form[:form_fields].cancel_button_name
json.set! :fields, form[:form_fields].fields.map(&:as_json)
json.set! :variables, form[:form_fields].variables
json.set! :csrf_token, csrf_token
json.set! :task_id, form[:task_id]
