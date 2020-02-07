module OrdersHelper
  EMPTY_VALUE = '—'.freeze

  def prettify_value(value, field = {})
    if value.kind_of?(Array)
      return value.map { |v| prettify_value(v, field) }.join(', ')
    end

    case field[:type]
      when 'datetime'
        prettify_date(value)
      when 'boolean'
        prettify_boolean(value)
      else value.to_s.presence || EMPTY_VALUE
    end
  end

  def prettify_date(value)
    if value.present?
      loc_datetime(value)
    else
      EMPTY_VALUE
    end
  end

  def prettify_boolean(value)
    if value
      '<i class="fas fa-check"></i>'.html_safe
    else
      ''
    end
  end

  def split_data(data, index = 10)
    data = (data.presence || {})
    visible, hidden = data.keys[0...index], data.keys[index..-1]
    [data.slice(*visible), data.slice(*hidden)]
  end

  def use_imprint?
    Rails.application.config.app[:use_imprint]
  end

  def expired_class(order)
    if !order.estimated_exec_date.nil?
      if order.estimated_exec_date <= Time.now
        'expired'
      elsif order.estimated_exec_date - Rails.application.config.app.fetch(:orders_expiration_warning_days, 1).days <= Time.now
        'about-to-expire'
      else
        ''
      end
    else
      ''
    end
  end

  def prepare_order_list(orders)
    orders.map do |order|
      static_fields = {
          code: {title: order.code, href: order_path(order.code)},
          order_type_code: order.order_type_name,
          state: {title: order_state_title(order), icon: order_state_icon(order)},
          created_at: loc_datetime(order.created_at),
          user: order.user_full_name,
          ext_code: order.ext_code,
          archived: order.archived,
          estimated_exec_date: loc_datetime(order.estimated_exec_date),
          options: {class: expired_class(order)}
      }

      fields_definition = order.order_type.fields.with_indifferent_access

      custom_fields = order.data.each_with_object({}) do |(key, value), fields|
        fields[key] = format_custom_field(value, fields_definition[key]['type'])
      end

      static_fields.merge(custom_fields)
    end
  end

  def format_custom_field(value, type)
    case type
    when 'datetime' then loc_datetime(value)
    else value
    end
  end
end
