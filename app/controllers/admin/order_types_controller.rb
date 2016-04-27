class Admin::OrderTypesController < ApplicationController
  before_action :authenticate_user!
  self.hbw_available = true

  before_filter :require_order_type, only: [:show, :activate, :dismiss, :destroy]

  def index
    @order_types = OrderType.active
  end

  def show
  end

  def create
    file_content = params.require(:order_type).permit(:file)[:file].read
    @order_type = OrderType.new(file: file_content)

    if @order_type.valid?
      if @order_type.save_if_differs!
        flash[:success] = t('.uploaded')
        render action: 'show'
      else
        flash[:error] = '%s: %s' % [t('.equal_exists'), @order_type.code]
        redirect_to action: 'index'
      end
    else
      flash[:error] = @order_type.errors.full_messages.join(', ')
      redirect_to action: 'index'
    end
  end

  def destroy
    @order_type.make_invisile
    flash[:success] = t('.destroyed')

    redirect_to admin_order_types_path
  end

  def activate
    @order_type.activate

    flash[:success] = t('.activated')
    redirect_to action: 'index'
  end

  def dismiss
    @order_type.destroy

    flash[:success] = t('.dismissed')
    redirect_to action: 'index'
  end

  def lookup
    render json: OrderType.lookup(params.require(:q)).to_json
  end

  private

  def require_order_type
    @order_type = OrderType.find(params.require(:id))
  end
end
