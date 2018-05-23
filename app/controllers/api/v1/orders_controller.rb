module API
  module V1
    class OrdersController < API::BaseController
      include HttpBasicAuthentication if !Rails.env.development? || ENV['HOMS_API_USE_AUTH']

      PARAMS_ATTRIBUTES = [:order_type_code, :user_email, :ext_code, :bp_id,
                           :bp_state, :state, :done_at, :archived, :estimated_exec_date]

      private

      def resource_set(resource = nil)
        resource ||= Order.find_by_code(params[:id])
        instance_variable_set("@#{resource_name}", resource)
      end

      def order_params
        p = params.require(:order).permit(*PARAMS_ATTRIBUTES).tap do |params|
          replace_user_email! params if params[:user_email]
          replace_order_type_code! params if params[:order_type_code]
        end

        params[:order][:data] ? p.merge(data: params[:order][:data]) : p
      end

      def replace_user_email!(params)
        user_id = User.id_from_email params[:user_email]
        replace!(params, :user_email, :user_id, user_id)
      end

      def replace_order_type_code!(params)
        order_type_id = OrderType.id_from_code params[:order_type_code]
        fail ActiveRecord::RecordNotFound unless order_type_id
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
