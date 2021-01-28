class CustomBooleanInput < SimpleForm::Inputs::BooleanInput
  def label_input(wrapper_options = nil)
    set_property(wrapper_options)
    render_checkbox
  end

  def set_property(wrapper_options = nil)
    @html_options = label_html_options.dup
    @html_options[:class] ||= []
    @html_options[:class].push(SimpleForm.boolean_label_class) if SimpleForm.boolean_label_class
    @merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
  end

  def render_checkbox
    if nested_boolean_style?
      build_hidden_field_for_checkbox +
        @builder.label(label_target, @html_options) do
          build_check_box_without_hidden_field(@merged_input_options) << <<-HTML.html_safe
            <span> #{label_text}</span>
          HTML
        end
    end
  end
end
