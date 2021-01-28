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
      password == user.try(:api_token) ? sign_in(user) : raise(Unauthorized)
    end
  end

  def unauthorized_http_basic
    head :unauthorized
  end
end
