module API
  module V1
    class ProfilesController < API::BaseController
      include HttpAuthentication if !Rails.env.development? || ENV['HOMS_API_USE_AUTH']

      PARAMS_ATTRIBUTES = [:order_type_code, :user_email].freeze

      private

      def profile_params
        p = params.require(:profile).permit(*PARAMS_ATTRIBUTES).tap do |params|
          replace_user_email! params if params[:user_email]
          replace_order_type_code! params if params[:order_type_code]
        end

        p.merge(data: params[:profile][:data])
      end

      def replace_user_email!(params)
        user_id = User.id_from_email params[:user_email]
        replace!(params, :user_email, :user_id, user_id)
      end

      def replace_order_type_code!(params)
        order_type_id = OrderType.id_from_code params[:order_type_code]
        replace!(params, :order_type_code, :order_type_id, order_type_id)
      end

      def replace!(params, code_key, id_key, id_val)
        record_not_found unless id_val

        params.delete code_key
        params[id_key] = id_val
      end
    end
  end
end
