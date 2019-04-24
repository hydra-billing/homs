module HBW
  class BaseController < ActionController::Base
    include Controller
    include HttpBasicAuthentication
    include HBW::Logger
    before_action :start
    after_action :log

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
