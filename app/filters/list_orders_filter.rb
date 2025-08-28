class ListOrdersFilter
  class EmptyUser < User
    def id
      'empty'
    end

    def full_name
      I18n.t('users.empty')
    end

    def save(*)
      raise NotImplementedError
    end
  end

  class << self
    def empty_user
      @empty_user ||= EmptyUser.new
    end
  end

  module Filters
    module_function

    def filter_by_date(rel, dates)
      {created_at_from:          'orders.created_at >= ?',
       created_at_to:            'orders.created_at <= ?',
       estimated_exec_date_from: 'orders.estimated_exec_date >= ?',
       estimated_exec_date_to:   'orders.estimated_exec_date <= ?'}.reduce(rel) do |r, (attr, condition)|
        if dates[attr].present?
          r.where(condition, dates[attr])
        else
          r
        end
      end
    end

    def filter_by_user_id(rel, value)
      has_empty = value.find { |v| v == 'empty' }
      values = value - %w(empty)

      if has_empty && values.present?
        rel.where('(user_id in (?) or user_id is null)', values)
      elsif has_empty
        rel.where(user_id: nil)
      else
        rel.where(user_id: values)
      end
    end

    def filter_by_custom_fields(relation, data)
      return relation unless data[:custom_fields]

      fields_definition = OrderType.find(data[:order_type_id]).fields
      string_field_names = get_string_field_names(fields_definition)
      date_field_names = get_date_field_names(fields_definition)

      filter_string_fields = data[:custom_fields].slice(*string_field_names).compact
      filter_date_fields = data[:custom_fields].slice(*date_field_names).compact

      apply_date_filters(relation.data_fields(filter_string_fields), filter_date_fields)
    end

    def get_string_field_names(fields_definition)
      fields_definition.select { |_k, v| %w(boolean number string).include? v[:type] }.keys
    end

    def get_date_field_names(fields_definition)
      fields_definition.select { |_k, v| v[:type] == 'datetime' }.keys
    end

    def apply_date_filters(relation, filter_date_fields)
      filter_date_fields.reduce(relation) do |rel, (name, value)|
        rel.data_datetime_range(name, value[:from], value[:to])
      end
    end

    def filter_by(rel, column, value)
      rel.where(column => value)
    end

    def filter_with_dispatch(rel, column, value)
      if value.nil?
        rel
      elsif respond_to?('filter_by_%s' % column)
        public_send('filter_by_%s' % column, rel, value)
      else
        filter_by(rel, column, value)
      end
    end
  end

  module Sorters
    module_function

    MAPPING = {
      'code'                => %w(code),
      'order_type_code'     => %w(order_types.code),
      'state'               => %w(state),
      'created_at'          => %w(created_at),
      'user'                => %w(users.name users.last_name),
      'ext_code'            => %w(ext_code),
      'archived'            => %w(archived),
      'estimated_exec_date' => %w(estimated_exec_date)
    }.freeze

    def sort_by(rel, column, order)
      if column
        if MAPPING.keys.include?(column)
          rel.includes(:order_type).includes(:user).reorder(render_order_by_clause(MAPPING[column], order)).order('orders.created_at DESC')
        else
          rel.reorder(Arel.sql("data->>'#{column}' #{order} nulls last")).order('orders.created_at DESC')
        end
      else
        rel
      end
    end

    def render_order_by_clause(conditions, order)
      conditions.map { |condition| "#{condition} #{order} nulls last" }.join(',')
    end
  end

  EMPTY_USER_ID = 'empty'.freeze

  delegate :empty_user, to: :'self.class'

  attr_reader :current_user, :params

  def initialize(current_user, params = {})
    @current_user = current_user
    @params = params
  end

  def list_orders(relation = Order.all)
    filtered_by_static_fields = %w(state order_type_id user_id archived).reduce(Filters.filter_by_date(relation, filter_values)) do |rel, column|
      Filters.filter_with_dispatch(rel, column, filter_values[column])
    end

    filtered_by_custom_fields = Filters.filter_by_custom_fields(filtered_by_static_fields, filter_values)

    Sorters.sort_by(filtered_by_custom_fields, sort_values[:sort_by], sort_values[:order] || 'asc')
  end

  def filter_values
    @filter_values ||= params.slice(*%w(state order_type_id archived user_id custom_fields)).merge(dates)
  end

  def sort_values
    @sort_values ||= params.slice(*%w(sort_by order))
  end

  def dates
    @dates ||=
      begin
        now = Time.current
        created_at_from = (params[:created_at_from] || (now - 1.day).beginning_of_day).try(:change, {offset: Time.zone.formatted_offset})
        created_at_to = (params[:created_at_to] || now.end_of_day).try(:change, {offset: Time.zone.formatted_offset})
        estimated_exec_date_from = params[:estimated_exec_date_from].try(:change, {offset: Time.zone.formatted_offset})
        estimated_exec_date_to = params[:estimated_exec_date_to].try(:change, {offset: Time.zone.formatted_offset})

        {created_at_from:,
         created_at_to:,
         estimated_exec_date_from:,
         estimated_exec_date_to:}.with_indifferent_access
      end
  end

  def users
    (params[:user_id] || []).map do |user_id|
      case user_id
      when EMPTY_USER_ID then empty_user
      when current_user.id.to_s then current_user
      else
        User.find(user_id)
      end
    end
  end

  private

  def filter?
    !!params[:filter]
  end
end
