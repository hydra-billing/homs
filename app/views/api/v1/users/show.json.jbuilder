json.user do
  json.partial! partial: 'api/v1/users/user', locals: { user: @user }
end
