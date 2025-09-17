class SessionsController < Devise::SessionsController
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:get_user)

  skip_before_action :assert_is_devise_resource!, :configure_permitted_parameters,
                     only: :sign_in_by_token

  before_action :set_greeting_text, only: :new

  def sign_in_by_token
    if sign_in_by_token_enabled? && params[:token] == token_config.fetch(:token)
      sign_in(token_user)
      redirect_to params.fetch(:redirect_to, '/')
    else
      flash[:error] = t('devise.failure.invalid', authentication_keys: t('devise.login'))
      redirect_to new_user_session_url
    end
  end

  def homs_config
    Rails.application.config.app
  end

  def set_greeting_text
    @greeting = homs_config.fetch(:greeting, {})
  end

  def token_config
    homs_config.fetch(:sessions, {}).fetch(:token_authentication, {})
  end

  def sign_in_by_token_enabled?
    token_config.fetch(:enabled, false) && token_config[:token].present?
  end

  def token_user
    User.find_by!(email: token_config.fetch(:sign_in_as))
  end

  def redirect_to_keycloak
    redirect_to keycloak_client.auth_url
  end

  def authenticate_by_keycloak
    result = get_user(params[:code])

    if result.success?
      handle_successful_keycloak_auth(result.value!)
    else
      handle_failed_keycloak_auth(result.failure)
    end
  end

  def get_user(auth_code)
    session_state = yield keycloak_client.authenticate!(auth_code)
    user = yield keycloak_user(session_state)

    cookies['session_state'] = {value: session_state, httponly: true}
    Success(user)
  end

  def destroy
    if use_keycloak?
      session_state = cookies.delete('session_state')

      keycloak_client
        .logout!(session_state)
        .either(->(logout_url) { logout_via_keycloak(logout_url) },
                ->(error) { after_keycloak_error(error) { super } })
    else
      super
    end
  end

  private

  def handle_successful_keycloak_auth(user)
    cef_logger.log_user_event(:login, {id: user.id, email: user.email}, request.headers)
    sign_in(user)

    redirect_to params.fetch(:redirect_to, '/')
  end

  def handle_failed_keycloak_auth(failure)
    user_data = {id: nil, email: nil}

    cef_logger.log_user_event(:failed_login, user_data, headers)
    cookies.delete('session_state')
    flash[:error] = render_sso_error(failure)

    redirect_to new_user_session_url
  end

  def logout_via_keycloak(logout_url)
    sign_out current_user
    set_flash_message! :notice, :signed_out
    redirect_to(logout_url)
  end

  def after_keycloak_error(error)
    yield if block_given?

    flash[:error] = keycloak_client_error(error)
  end

  def keycloak_client
    HOMS.container[:keycloak_client]
  end

  def keycloak_client_error(error)
    t("devise.failure.sso.#{error[:code]}")
  end

  def cef_logger
    HOMS.container[:cef_logger]
  end

  def render_sso_error(failure)
    case failure
    in ::Dry::Schema::Result
      logger.error("Keycloak authentication user attribute error: #{failure.errors.to_h}")

      t('devise.failure.sso.user_attributes_error', message: failure.errors.to_h)
    else
      logger.error("Keycloak authentication error: #{failure}")

      keycloak_client_error(failure)
    end
  end
end
