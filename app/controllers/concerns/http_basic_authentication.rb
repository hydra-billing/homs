module HttpBasicAuthentication
  class Unauthorized < ActionController::ActionControllerError; end

  extend ActiveSupport::Concern

  included do
    before_action :perform_http_basic_authentication, if: -> { !defined?(current_user) || !current_user }

    rescue_from Unauthorized, with: :unauthorized_http_basic
  end

  protected

  def perform_http_basic_authentication
    realm = Rails.application.secrets.http_basic_realm || 'Latera OMS'

    authenticate_or_request_with_http_basic(realm) do |email, password|
      return unless email && password

      user = User.find_by_email(email)

      if password == user.try(:api_token)
        HOMS.container[:cef_logger].log_user_event(:login, {id: user.id, email: user.email}, request.headers)

        sign_in(user)
      else
        HOMS.container[:cef_logger].log_user_event(:failed_login, {id: nil, email: email}, request.headers)

        raise(Unauthorized)
      end
    end
  end

  def unauthorized_http_basic
    head :unauthorized
  end
end
