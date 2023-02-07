module KeycloakUtils
  extend ActiveSupport::Concern

  Dry::Schema.load_extensions(:monads)

  UserDataSchema = Dry::Schema.JSON do
    required(:email).filled(:string)
    required(:given_name).filled(:string)
    optional(:family_name).filled(:string)
    optional(:company).filled(:string)
    optional(:department).filled(:string)
    required(:resource_access).value(:hash) do
      required(:homs).value(:hash) do
        required(:roles).filled(:array, size?: 1) do
          each(included_in?: User.roles_list)
        end
      end
    end
  end

  def validate_user_data(access_token)
    UserDataSchema.(access_token.data)
      .to_monad
      .fmap { |r| r.to_h.merge(role: r.to_h.dig(:resource_access, :homs, :roles).first) }
  end

  def use_keycloak?
    return false unless sso_enabled?

    if sso_enabled? && !regular_login_enabled?
      true
    else
      authenticated_by_keycloak?
    end
  end

  def sso_enabled?
    Rails.application.config.app.fetch(:sso, {}).fetch(:enabled)
  end

  def regular_login_enabled?
    Rails.application.config.app.fetch(:sso, {}).fetch(:use_regular_login)
  end

  def authenticated_by_keycloak?
    HOMS.container[:keycloak_client]&.authenticated?(cookies['session_state'])
  end
end
