json.extract!(order,
              :id,
              :code,
              :ext_code,
              :bp_id,
              :bp_state,
              :state,
              :archived,
              :data)
json.done_at order.done_at ? order.done_at.iso8601 : nil
json.estimated_exec_date order.estimated_exec_date ? order.estimated_exec_date.iso8601 : nil
json.order_type_code order.order_type.code
json.user_email order.user.try(:email)
json.attachments order.attachments
