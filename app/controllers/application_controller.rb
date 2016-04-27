class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  class_attribute :hbw_available
  self.hbw_available = false
  helper_method :hbw_available?

  before_action -> { ENV['DISABLE_PRY'] = nil }

  protected

  def json_request?
    request.format.json?
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def flash_messages
    %i(success notice error).reduce([]) do |messages, type|
      if flash.key?(type)
        messages + [[type, flash[type]]]
      else
        messages
      end
    end
  end
  helper_method :flash_messages
end
