class OrdersController < API::BaseController
  before_action :authenticate_user!
  self.hbw_available = true

  respond_to :html

  before_action :set_order, only: [:new, :create]

  def show
  end

  def get_order_data
    @order = Order.find_by_code(params['order_code'])

    render partial: 'data', locals: { data: @order.data }
  end

  # GET /orders/search_by/{:code | :ext_code}/
  def search_by
    @criteria = "#{Order.human_attribute_name(params[:field])}: "\
                "'#{params[:value]}'"
    resource_set Order.find_by!(params[:field] => params[:value])
    render action: :show
  end

  def index
    super(list_filter.list_orders)
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
    @order.data = params[:order]
    @order.user_id = current_user.id

    if @order.save
      redirect_to order_url(@order.code)
    else
      render 'new'
    end
  end

  def update
    @order.data = params[:order]

    if @order.save
      redirect_to order_url(@order.code)
    else
      render 'edit'
    end
  end

  def set_order
    @order = Order.new
  end

  protected

  def resource_get
    instance_variable_get("@#{resource_name}")
  end

  helper_method \
  def list_filter
    @filter ||= ListOrdersFilter.new(current_user, filter_params)
  end

  def filter_params
    user_ids = params[:filter] ? params[:user_id] : [current_user.id, 'empty']

    params.permit(:state, :order_type_id, :archived,
                  :created_at_from, :created_at_to,
                  :filter, user_id: []).reverse_merge(user_id: user_ids,
                                                      archived: '0',
                                                      state: nil)
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
end
