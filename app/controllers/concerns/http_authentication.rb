module HttpAuthentication
  class Unauthorized < ActionController::ActionControllerError; end

  extend ActiveSupport::Concern

  included do
    before_action :check_token
    before_action :perform_http_authentication, if: -> { !defined?(current_user) || !current_user }

    rescue_from Unauthorized, with: :unauthorized_http_basic
  end

  protected

  def perform_http_authentication
    realm = Rails.application.secrets.http_basic_realm || 'Latera OMS'

    if token_present?
      authenticate_by_keycloak
    else
      basic_authenticate(realm)
    end
  end

  def unauthorized_http_basic
    head :unauthorized
  end

  def check_token
    @token_present = request.headers.include?('Authorization') && request.headers['Authorization'].start_with?('Token token=')
  end

  def token_present?
    @token_present
  end

  def authenticate_by_keycloak
    authenticate_or_request_with_http_token do |token, _options|
      HOMS.container[:keycloak_client].introspect_token(token).either(
        proc { sign_in_by_token(token) },
        proc { fail_auth(nil) }
      )
    end
  end

  def basic_authenticate(realm)
    authenticate_or_request_with_http_basic(realm) do |email, password|
      return unless email && password

      user = User.find_by_email(email)

      if password == user.try(:api_token)
        HOMS.container[:cef_logger].log_user_event(:login, {id: user.id, email: user.email}, request.headers)

        sign_in(user)
      else
        fail_auth(email)
      end
    end
  end

  private

  def sign_in_by_token(token)
    user = User.from_keycloak(::Hydra::Keycloak::Token.new(token))

    HOMS.container[:cef_logger].log_user_event(:login, {id: user.id, email: user.email}, request.headers)
    sign_in(user)
  end

  def fail_auth(email)
    HOMS.container[:cef_logger].log_user_event(:failed_login, {id: nil, email: email}, request.headers)

    raise(Unauthorized)
  end
end
