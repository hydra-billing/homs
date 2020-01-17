module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      if env['warden'].user.nil?
        reject_unauthorized_connection
      else
        env['warden'].user
      end
    end
  end
end
