module UiElementsHelper
  include DatetimeFormat

  def order_attribute_picker(name)
    content_tag(:select,
                name:,
                data:     {
                  allowClear:  false,
                  placeholder: I18n.t('helpers.custom_fields_filter.placeholder')
                },
                disabled: true,
                class:    'form-control order_attribute-picker') {}
  end

  def datetime_picker(name, options = {})
    value = if options[:value].present?
              options[:value].strftime(datetime_format)
            end

    content_tag(:div, class: 'form-group') do
      content_tag(:div,
                  data:  {showClear: true},
                  class: "input-group date datetime-picker #{options[:class]}") do
        content_tag(:input,
                    name:,
                    type:  'text',
                    class: 'form-control',
                    value:) do
          content_tag(:span, class: 'input-group-addon') do
            content_tag(:span, class: 'fas fa-calendar') {}
          end
        end
      end
    end
  end

  def user_picker(name, value: [])
    content_tag(:select, name:     "#{name}[]",
                         data:     {
                           allowClear:  true,
                           placeholder: I18n.t('helpers.enter_user'),
                           ajax:        {url: lookup_users_path}
                         },
                         multiple: true,
                         class:    'user-picker') do
      options_for_select(value.map { |u| [u.full_name, u.id] }, value.map(&:id))
    end
  end

  def order_state_picker(name, value: nil)
    content_tag(:select, name:,
                         data:  {
                           allowClear:  true,
                           placeholder: I18n.t('helpers.enter_state')
                         },
                         class: 'form-control order_state-picker') do
                           '<option></option>'.html_safe + options_for_select(order_states_for_select, value)
                         end
  end

  def order_type_picker(name, value: nil)
    content_tag(:select, name:,
                         data:  {
                           allowClear:  true,
                           placeholder: I18n.t('helpers.enter_order_type')
                         },
                         value:,
                         class: 'form-control order_type-picker') do
                           '<option></option>'.html_safe + options_for_select(order_types_for_select, value)
                         end
  end

  def order_archived_picker(name, value: nil)
    content_tag(:select, name:,
                         data:  {
                           allowClear:  true,
                           placeholder: I18n.t('helpers.enter_archived')
                         },
                         class: 'form-control order_archived-picker') do
      '<option></option>'.html_safe + options_for_select([
                                                           [t('helpers.yes_no.yes'), true],
                                                           [t('helpers.yes_no.no'), false]
                                                         ], value)
    end
  end
end
