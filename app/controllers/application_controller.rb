class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  class_attribute :hbw_available
  self.hbw_available = false
  helper_method :hbw_available?

  before_action -> { ENV['DISABLE_PRY'] = nil }

  def authenticate_user!
    if use_keycloak?
      session_state = cookies['session_state']
      authorization_result = HOMS.container[:keycloak_client].authorize!(session_state)

      if authorization_result.failure? && current_user
        sign_out @user
      end
    end

    super
  end

  protected

  def keycloak_user(session_state)
    HOMS.container[:keycloak_client].access_token(session_state).fmap do |access_token|
      User.from_keycloack(access_token)
    end
  end

  def use_keycloak?
    return false unless keycloak_enabled?

    if keycloak_enabled? && !regular_login_enabled?
      true
    else
      authenticated_by_keycloak?
    end
  end

  def keycloak_enabled?
    Rails.application.config.app.fetch(:SSO, {}).fetch(:enabled)
  end

  def regular_login_enabled?
    Rails.application.config.app.fetch(:SSO, {}).fetch(:use_regular_login)
  end

  def authenticated_by_keycloak?
    HOMS.container[:keycloak_client]&.authenticated?(cookies['session_state'])
  end

  def json_request?
    request.format.json?
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def admin_only
    unless current_user.admin?
      flash[:error] = t('access_denied')

      redirect_to '/'
    end
  end

  def flash_messages
    %i(success notice alert error).reduce([]) do |messages, type|
      if flash.key?(type)
        messages + [[type, flash[type]]]
      else
        messages
      end
    end
  end
  helper_method :flash_messages
end
