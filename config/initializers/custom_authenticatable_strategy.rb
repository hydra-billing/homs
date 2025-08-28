require 'devise/strategies/database_authenticatable'

module Devise
  module Strategies
    class CustomAuthenticatable < DatabaseAuthenticatable
      def authenticate!
        super

        if user&.blocked
          @user = nil
          self.fail(:blocked) # this is not Ruby's `fail`, it is Warden's `fail`
        end
      end
    end
  end
end
