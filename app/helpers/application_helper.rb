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

  def boolean_indicator(boolean)
    boolean ? tag(:span, class: %w(glyphicon glyphicon-ok)) : ''
  end

  def order_state_indicator(order)
    title = I18n.t(Order.state_i18n_key(order.state))
    icon = if order.to_execute?
             'fa-square-o'
           elsif order.in_progress?
             'fa-gears'
           else
             'fa-check-square-o'
           end

    "<span><i class='fa #{icon}'></i> #{title}</span>".html_safe
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
      locale: I18n.locale
    }

    if defined? @hbw_options
      default_options.merge(@hbw_options)
    else
      default_options
    end
  end
end
