Warden::Manager.after_authentication do |user, auth, _opts|
  HOMS.container[:cef_logger].log_user_event(
    :login,
    {id: user.id, email: user.email},
    auth.request.headers
  )
end

Warden::Manager.before_logout do |user, auth, _opts|
  HOMS.container[:cef_logger].log_user_event(
    :logout,
    {id: user.id, email: user.email},
    auth.request.headers
  )
end

Warden::Manager.before_failure(scope: :user) do |env, opts|
  if opts[:action] == 'unauthenticated' && opts[:attempted_path] == '/users/sign_in'
    headers = env['action_controller.instance'].headers
    params  = env['action_controller.instance'].params
    user = {
      id:    nil,
      email: params.try(:[], :user).try(:[], :email)
    }

    HOMS.container[:cef_logger].log_user_event(:failed_login, user, headers)
  end
end
