module HttpAuthHelper
  def add_http_auth_header(email, password)
    request.env['HTTP_AUTHORIZATION'] =
      ActionController::HttpAuthentication::Basic
      .encode_credentials(email, password)
  end

  def disable_http_basic_authentication(controller_class)
    allow_any_instance_of(controller_class).to receive(
      :perform_http_basic_authentication).and_return(true)
  end
end
