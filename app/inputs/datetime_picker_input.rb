class DatetimePickerInput < SimpleForm::Inputs::Base
  include DatetimeFormat
  def input(*)
    template.content_tag(:div, class: %w(input-group date datetime-picker), language: I18n.locale) do
      @builder.text_field(attribute_name,
                          class: 'form-control',
                          value: value.present? ? l(value, format: datetime_format) : '') <<
        @builder.hidden_field(attribute_name,
                              class: 'form-control iso8601',
                              value: value.try(:iso8601)) << <<-HTML.html_safe
        <span class="input-group-addon">
          <span class="fas fa-calendar"></span>
        </span>
      HTML
    end
  end

  def value
    return @value if defined? @value

    raw_value = options[:value].presence
    @value = case raw_value
             when String then Time.iso8601(raw_value)
             else
               raw_value
             end
  end
end
