module KeycloakAuthentication
  class Unauthorized < ActionController::ActionControllerError; end

  extend ActiveSupport::Concern

  included do
    before_action :perform_keycloak_authentication, if: -> { !defined?(current_user) || !current_user }

    rescue_from Unauthorized, with: :unauthorized_keycloak
  end

  protected

  def perform_keycloak_authentication
    if use_keycloak?
      session_state = cookies['session_state']
      authorization_result = HOMS.container[:keycloak_client].authorize!(session_state)

      if authorization_result.success?
        user = keycloak_user(session_state)

        sign_in(user)
      end
    end

    raise(Unauthorized)
  end

  def unauthorized_keycloak
    head :unauthorized
  end

  def keycloak_user(session_state)
    HOMS.container[:keycloak_client].access_token(session_state).bind do |access_token|
      User.from_keycloack(access_token)
    end
  end
end
