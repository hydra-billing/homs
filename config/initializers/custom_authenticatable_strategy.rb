require 'devise/strategies/database_authenticatable'

module Devise
  module Strategies
    class CustomAuthenticatable < DatabaseAuthenticatable
      def authenticate!
        super

        if user&.blocked
          @user = nil
          fail(:blocked)
        end
      end
    end
  end
end
