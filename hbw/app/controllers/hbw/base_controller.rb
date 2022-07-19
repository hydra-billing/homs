module HBW
  class BaseController < ActionController::Base
    include Controller
    include HttpAuthentication
    include KeycloakUtils
    include HBW::Logger
    before_action :start, unless: -> { Rails.env.test? }
    after_action :log, unless: -> { Rails.env.test? }
    before_action :get_access_token, if: -> { keycloak_enabled? }

    protected

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

    def get_access_token
      @access_token = token_from_headers || local_token
    end

    def token_from_headers
      pattern = /^Bearer /
      header  = request.headers['Authorization']
      header.gsub(pattern, '') if header&.match(pattern)
    end

    def local_token
      HOMS.container[:keycloak_client].access_token(cookies['session_state']).value_or(nil)
    end
  end
end
