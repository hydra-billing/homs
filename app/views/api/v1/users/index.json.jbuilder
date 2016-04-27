json.users do
  json.partial! partial: 'api/v1/users/user', collection: @users, as: :user
end
