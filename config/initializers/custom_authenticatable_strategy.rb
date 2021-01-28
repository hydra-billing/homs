require 'devise/strategies/database_authenticatable'

module Devise
  module Strategies
    class CustomAuthenticatable < DatabaseAuthenticatable
      def authenticate!
        super

        if user && user.blocked
          @user = nil
          raise(:blocked)
        end
      end
    end
  end
end
