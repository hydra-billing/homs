json.extract! profile, :id, :data

json.order_type_code profile.order_type.code
json.user_email profile.user.try(:email)
