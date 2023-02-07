module HBW
  class BaseController < ActionController::Base
    include Controller
    include HttpAuthentication
    include KeycloakUtils
    include HBW::Logger

    include Dry::Monads::Do.for(:auth_service_user)

    before_action :start, unless: -> { Rails.env.test? }
    before_action :set_service_user_cookie, if: -> { !Rails.env.test? && auth_as_sso_service_user? }
    before_action :get_access_token, if: -> { sso_enabled? }
    after_action :log, unless: -> { Rails.env.test? }

    protected

    def set_service_user_cookie
      if cookies['service_user_session_state'].present?
        authorized = HOMS.container[:keycloak_client].authorize!(cookies['service_user_session_state'])

        auth_service_user if authorized.failure?
      else
        auth_service_user
      end
    end

    def current_user_identifier
      user_identifier || current_user.email
    end

    def token_user_identifier
      ::Hydra::Keycloak::Token.new(@access_token)['preferred_username'] if @access_token
    end

    private

    def start
      @start = Time.now.to_f
    end

    def log
      log_duration('info', @start)
    end

    def auth_service_user
      session_state = yield HOMS.container[:keycloak_client].authenticate_by_password!(
        bpm_config.fetch(:login),
        bpm_config.fetch(:password)
      )

      cookies['service_user_session_state'] = {value: session_state, httponly: true}
    end

    def get_access_token
      @access_token = token_from_headers || local_token || service_user_token
    end

    def token_from_headers
      pattern = /^Bearer /
      header  = request.headers['Authorization']
      header.gsub(pattern, '') if header&.match(pattern)
    end

    def local_token
      HOMS.container[:keycloak_client].access_token(cookies['session_state']).fmap(&:source).value_or(nil)
    end

    def service_user_token
      HOMS.container[:keycloak_client].access_token(cookies['service_user_session_state']).fmap(&:source).value_or(nil)
    end

    def bpm_config
      (Settings::BPM[Rails.env] || {}).deep_symbolize_keys
    end

    def auth_as_sso_service_user?
      sso_enabled? && regular_login_enabled? && token_from_headers.nil? && !authenticated_by_keycloak?
    end
  end
end
