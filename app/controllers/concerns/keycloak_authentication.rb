module KeycloakAuthentication
  class Unauthorized < ActionController::ActionControllerError; end

  extend ActiveSupport::Concern

  included do
    before_action :perform_keycloak_authentication, if: -> { !defined?(current_user) || !current_user }

    rescue_from Unauthorized, with: :unauthorized_keycloak
  end

  protected

  def perform_keycloak_authentication
    authenticate_or_request_with_http_token do |token, options|
      HOMS.container[:keycloak_client].introspect_token(token).either(
        proc do
          user = User.from_keycloack(token)

          sign_in(user)
        end,

        proc do
          raise(Unauthorized)
        end
      )
    end
  end

  def unauthorized_keycloak
    head :unauthorized
  end
end
