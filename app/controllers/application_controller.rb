class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  class_attribute :hbw_available
  self.hbw_available = false
  helper_method :hbw_available?

  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:keycloak_user)
  include KeycloakUtils

  before_action -> { ENV['DISABLE_PRY'] = nil }
  before_action :configure_permitted_parameters, if: :devise_controller?

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

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def keycloak_user(session_state)
    access_token = yield HOMS.container[:keycloak_client].access_token(session_state)
    validated_user_data = yield validate_user_data(access_token)

    Success(User.from_keycloak(validated_user_data))
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
