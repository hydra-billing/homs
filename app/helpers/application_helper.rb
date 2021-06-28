module ApplicationHelper
  include Rails.application.routes.url_helpers

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
    date_range.each_with_object({}) { |(k, v), range| range[k] = DateTime.iso8601(v).strftime(datetime_format) if v.present?; }
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

  def loc_datetime(datetime)
    case datetime
    when Time, DateTime then datetime.strftime(datetime_format)
    when String then DateTime.iso8601(datetime).strftime(datetime_format)
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
      userIdentifier:                current_user.email,
      widgetURL:                     root_url,
      widgetPath:                    '/widget',
      entity_class:                  'order',
      availableTasksButtonContainer: '#hbw-tasks-list-button',
      availableTaskListContainer:    '#hbw-task-list',
      taskListPath:                  'tasks',
      showNotifications:             true,
      locale:                        {
        code:           I18n.locale,
        dateTimeFormat: js_datetime_format
      }
    }

    if defined? @hbw_options
      default_options.merge(@hbw_options)
    else
      default_options
    end
  end

  def list_orders_path
    root_path
  end

  def list_orders_url
    root_url
  end
end
