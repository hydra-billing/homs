json.users do
  json.partial! partial: 'users/user', collection: @users, as: :user
end
