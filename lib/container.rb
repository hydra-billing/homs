require 'dry-container'
require 'dry-auto_inject'
require 'dry/container/stub'
require 'cef_logger'

module HOMS
  class Container
    extend Dry::Container::Mixin

    register(:cef_logger) { CEFLogger.new(enabled: Rails.application.config.app.fetch(:cef_logger, false)) }

    sso_config = Rails.application.config.app.fetch(:SSO, {})
    if sso_config.fetch(:enabled)
      keycloak_config = sso_config.fetch(:keycloak, {})
      redis_config    = Rails.application.config.app.fetch(:redis, {})
      register(:keycloak_client,
               Hydra::Keycloak::ClientCreator.call(
                 config: {
                   auth_server_url:      keycloak_config.fetch(:auth_server_url),
                   realm:                keycloak_config.fetch(:realm),
                   client_id:            keycloak_config.fetch(:client_id),
                   redirect_uri:         keycloak_config.fetch(:redirect_uri),
                   secret:               keycloak_config.fetch(:secret),
                   logout_redirect:      keycloak_config.fetch(:logout_redirect),
                   store_client:         'redis',
                   store_client_options: {redis_host: redis_config.fetch(:host),
                                          redis_port: redis_config.fetch(:port)}
                 }
               ))
    end
  end

  Inject = Dry::AutoInject(Container)

  def self.container
    Container
  end

  def self.inject
    Inject
  end
end
