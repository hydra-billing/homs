module API
  module V1
    class UsersController < API::BaseController
      include HttpBasicAuthentication if !Rails.env.development? || ENV['HOMS_API_USE_AUTH']

      PARAMS_ATTRIBUTES = [:name, :last_name, :middle_name, :company,
                           :department, :email, :role, :password, :external,
                           :blocked]

      private

      def user_params
        params.require(:user).permit(*PARAMS_ATTRIBUTES).tap do |hash|
          hash[:password_confirmation] = hash[:password] if
            hash[:password]
        end
      end

      def resource_set(resource = nil)
        resource ||= resource_class.find_by_email!(params[:id])
        super resource
      end
    end
  end
end
