module OrdersHelper
  EMPTY_VALUE = '—'.freeze

  def prettify_value(value, field = {})
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
      '<i class="fa fa-check"></i>'.html_safe
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
end
