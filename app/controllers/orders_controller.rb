class OrdersController < API::BaseController
  extend Imprint::Mixin

  inject['services.order_printing_service']

  before_action :authenticate_user!
  self.hbw_available = true

  respond_to :html

  before_action :set_order, only: [:new, :create]

  def show
  end

  # GET /orders/search_by/{:code | :ext_code}/
  def search_by
    @criteria = "#{Order.human_attribute_name(params[:field])}: "\
                "'#{params[:value]}'"
    resource_set Order.find_by!(params[:field] => params[:value])
    render action: :show
  end

  def index
    orders = list_filter.list_orders

    render 'orders/index', locals: {orders: orders.page(page_params[:page]).per(page_params[:page_size]), total_items: orders.size}
  end

  def list
    render 'orders/list', locals: {orders: list_filter.list_orders.page(page_params[:page]).per(page_params[:page_size])}
  end

  def edit
  end

  def new
    if request.xml_http_request?
      @order.order_type_id = params[:order_type_id]
      render partial: params[:partial_name]
    else
      @order.order_type_id = OrderType.active.first.id
    end
  end

  def create
    @order.order_type_id = params[:order_type_id] || OrderType.active.first.id
    @order.data = params[:order][:data].permit!
    @order.user_id = current_user.id
    @order.update_attributes(order_common_params)

    if @order.save
      redirect_to order_url(@order.code)
    else
      render 'new'
    end
  end

  def update
    @order.data = params[:order][:data].permit!
    @order.update_attributes(order_common_params)

    if @order.save
      redirect_to order_url(@order.code)
    else
      render 'edit'
    end
  end

  def set_order
    @order = Order.new
  end

  def get_order_type_attributes
    order_type = OrderType.find(params[:id])

    render json: {options: order_type.fields}
  end

  protected

  def resource_get
    instance_variable_get("@#{resource_name}")
  end

  helper_method \
  def list_filter
    @filter ||= order_printing_service.build_filter(current_user, params)
  end

  def record_not_found
    if @criteria.nil?
      flash[:error] = t('record_not_found')
    else
      flash[:error] = t('orders.search_by_not_found', criteria: @criteria)
    end

    redirect_to orders_path
  end

  def resource_set(resource = nil)
    resource ||= Order.find_by!(code: params[:id])
    instance_variable_set("@#{resource_name}", resource)
  end

  private

  def order_common_params
    params.require(:order).permit(:estimated_exec_date)
  end

  def sort_params
    params.permit(:sort_by, :order)
  end
end
