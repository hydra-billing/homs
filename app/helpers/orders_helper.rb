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
end
