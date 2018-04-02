require 'minio'

module API
  module V1
    class AttachmentsController < API::BaseController
      skip_before_action :resource_set
      include Minio
      extend Minio::Mixin

      inject['minio_adapter']

      include HttpBasicAuthentication if !Rails.env.development? || ENV['HOMS_API_USE_AUTH']

      PARAMS_ATTRIBUTES = [:order_id, :attachments, :attachment_id]

      def create
        ActiveRecord::Base.transaction do
          minio_adapter.save_file(params[:attachments], params[:order_id])
        end

        render :json,  nothing: true, status: :created
      end

      def show
        attachments = Order.find(params[:id]).attachments
        render :show, locals: {attachments: attachments}
      end

      def destroy
        minio_adapter.destroy(params[:id])
        head :no_content
      end
    end
  end
end
