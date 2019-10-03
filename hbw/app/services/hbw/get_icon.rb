module HBW
  module GetIcon
    def get_icon(entity_class)
      bp_code = definition['processDefinition'].definition['key']
      buttons = config[:entities].fetch(entity_class.to_sym)[:bp_toolbar][:entity_type_buttons]

      process_buttons = filter_buttons_by_code(buttons, bp_code)

      process_buttons[0][:fa_class] if process_buttons[0]
    end

    def filter_buttons_by_code(buttons, bp_code)
      buttons.map do |_, value|
        value.find { |e| e[:bp_code] == bp_code }
      end.compact
    end
  end
end
