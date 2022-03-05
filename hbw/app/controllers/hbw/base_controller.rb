module HBW
  class BaseController < ActionController::Base
    include Controller
    include HttpBasicAuthentication if !keycloak_enabled?
    include KeycloakAuthentication if keycloak_enabled?
    include HBW::Logger
    before_action :start, unless: -> { Rails.env.test? }
    after_action :log, unless: -> { Rails.env.test? }

    protected

    def current_user_identifier
      user_identifier || current_user.email
    end

    private

    def start
      @start = Time.now.to_f
    end

    def log
      log_duration('info', @start)
    end
  end
end
