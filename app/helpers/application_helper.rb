module ApplicationHelper
  def roles_for_select
    User.roles.keys.map { |role| [t(User.role_i18n_key(role)), role] }
  end

  def order_states_for_select
    Order.states.keys.each_with_index.map do |state, i|
      [I18n.t(Order.state_i18n_key(state)), i.to_s]
    end
  end

  def order_types_for_select
    OrderType.active.map do |order_type|
      [order_type.name, order_type.id]
    end
  end

  def custom_fields_for_filter(order_type, attributes)
    type_attributes = OrderType.find(order_type).fields.with_indifferent_access
    prepared_fields = attributes.each_with_object({}) do |(attr, val), fields|
      value = val
      value[:localized] = localize_date_range(val) if type_attributes[attr][:type] == 'datetime'

      fields[attr] = {value: value}
    end

    type_attributes.slice(*attributes.keys).deep_merge(prepared_fields)
  end

  def localize_date_range(date_range)
    date_range.reduce({}) { |range, (k,v)| range[k] = DateTime.iso8601(v).strftime(datetime_format) if v.present?; range }
  end

  def boolean_indicator(boolean)
    boolean ? tag(:span, class: %w(glyphicon glyphicon-ok)) : ''
  end

  def order_state_indicator(order)
    title = order_state_title(order)
    icon = order_state_icon(order)

    "<span><i class='#{icon}'></i> #{title}</span>".html_safe
  end

  def order_state_title(order)
    I18n.t(Order.state_i18n_key(order.state))
  end

  def order_state_icon(order)
    if order.to_execute?
      'far fa-square'
    elsif order.in_progress?
      'fas fa-cogs'
    else
      'far fa-check-square'
    end
  end

  def yes_no
    %w(yes no).each_with_index.map do |e, i|
      [t("helpers.yes_no.#{e}"), i.zero?]
    end
  end

  def loc_date(date)
    case
      when Time, DateTime then I18n.l(date, format: :date)
      when String then I18n.l(DateTime.iso8601(date), format: :date)
      else ''
    end
  end

  def loc_datetime(datetime)
    case datetime
      when Time, DateTime then I18n.l(datetime, format: :datetime)
      when String then I18n.l(DateTime.iso8601(datetime), format: :datetime)
      else ''
    end
  end

  def bootstrap_class_for(flash_type)
    case flash_type
    when 'success' then 'alert alert-dismissable alert-success'   # Green
    when 'error'   then 'alert alert-dismissable alert-danger'    # Red
    when 'alert'   then 'alert alert-dismissable alert-warning'   # Yellow
    when 'notice'  then 'alert alert-dismissable alert-info'      # Blue
    else flash_type.to_s
    end
  end

  def use_imprint?
    Rails.application.config.app[:use_imprint]
  end

  def hbw_options
    default_options = {
      widgetPath: '/widget',
      tasksMenuContainer: '#hbw-tasks',
      tasksMenuButtonContainer: '#hbw-tasks-list-button',
      entity_class: 'order',
      locale: I18n.locale,
      fetch_all: true
    }

    if defined? @hbw_options
      default_options.merge(@hbw_options)
    else
      default_options
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
