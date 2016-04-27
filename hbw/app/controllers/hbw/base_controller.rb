module HBW
  class BaseController < ActionController::Base
    include Controller
    include HttpBasicAuthentication

    protected

    def current_user_identifier
      user_identifier || current_user.email
    end
  end
end
