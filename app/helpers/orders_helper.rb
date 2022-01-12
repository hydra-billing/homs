module OrdersHelper
  EMPTY_VALUE = '—'.freeze

  FILE_LIST_SCHEMA = Dry::Schema.Params do
    required(:file_list).array(:hash) do
      required(:url).filled
      required(:name).filled
      required(:origin_name).filled
      required(:real_name).filled
      required(:field_name).filled
      required(:upload_time).filled
      required(:end_point).filled
      required(:bucket).filled
    end
  end

  def prettify_value(value, field = {})
    if value.is_a?(Array)
      return value.map { |v| prettify_value(v, field) }.join(', ')
    end

    case field[:type]
    when 'datetime'
      prettify_date(value)
    when 'boolean'
      prettify_boolean(value)
    when 'json'
      prettify_json(value)
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

  def prettify_json(value)
    if value.present?
      parsed_value = JSON.parse(value)
      if FILE_LIST_SCHEMA.(file_list: parsed_value).success?
        render partial: 'orders/file_list', locals: {files: parsed_value}
      else
        value.to_s
      end
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
    visible = data.keys[0...index]
    hidden = data.keys[index..]
    [data.slice(*visible), data.slice(*hidden)]
  end

  def use_imprint?
    Rails.application.config.app[:use_imprint]
  end

  def expired_class(order)
    if order.estimated_exec_date.nil?
      ''
    elsif order.estimated_exec_date <= Time.now
      'expired'
    elsif order.estimated_exec_date - Rails.application.config.app.fetch(:orders_expiration_warning_days, 1).days <= Time.now
      'about-to-expire'
    else
      ''
    end
  end

  def prepare_order_list(orders)
    orders.map do |order|
      static_fields = {
        code:                {title: order.code, href: order_path(order.code)},
        order_type_code:     order.order_type_name,
        state:               {title: order_state_title(order), icon: order_state_icon(order)},
        created_at:          loc_datetime(order.created_at),
        user:                order.user_full_name,
        ext_code:            order.ext_code,
        archived:            order.archived,
        estimated_exec_date: loc_datetime(order.estimated_exec_date),
        options:             {class: expired_class(order)}
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
