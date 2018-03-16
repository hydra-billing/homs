require 'minio'

module API
  module V1
    class OrdersController < API::BaseController
      include Minio
      extend Minio::Mixin

      inject['minio_adapter']

      include HttpBasicAuthentication if !Rails.env.development? || ENV['HOMS_API_USE_AUTH']

      PARAMS_ATTRIBUTES = [:order_type_code, :user_email, :ext_code, :bp_id,
                           :bp_state, :state, :done_at, :archived, :estimated_exec_date]

      def create
        order_params = parse_params

        resource_set(resource_class.new(order_params[:order_params]))

        ActiveRecord::Base.transaction do
          if resource_get.save
            if order_params[:attachments].present?
              order_params[:attachments].each do |file|
                minio_adapter.save_file(file.symbolize_keys, resource_get.id)
              end
            end
          end
        end

        render :show, status: :created
      end

      def update
        order_params = parse_params

        ActiveRecord::Base.transaction do
          if resource_get.update(order_params[:order_params])
            if order_params[:attachments].present?
              order_params[:attachments].each do |file|
                minio_adapter.save_file(file.symbolize_keys, resource_get.id)
              end
            end
          end
        end

        render :show
      end

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

      def parse_params
        order_param = resource_params
        attachments = order_param[:data].try(:delete, 'uploadedFile') || []

        if attachments.present?
          attachments = JSON.parse(attachments)
        end

        {order_params: order_param, attachments: attachments}
      end
    end
  end
end
