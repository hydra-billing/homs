module Features
  module OrdersHelper
    include DatetimeFormat

    def click_on_calendar(class_name)
      page.find(".#{class_name} .input-group-addon").click
      page.find('nav').click
    end

    def set_date(class_name, day)
      page.find(".#{class_name} .fa-calendar").click
      expect(page.find(".#{class_name} .day", text: day.to_s).text).to have_content(day)
      page.find(".#{class_name} .day", text: day.to_s).click
      page.find('nav').click
    end

    def header
      page.find('h2')
    end

    def find_by_title(title)
      page.find("[title='#{title}']")
    end

    def active_tab(text)
      page.all('li.active').find { |node| node.find('a', text: text) }
    end

    def tab(text)
      page.all('a[data-toggle="tab"]').select { |x| x.text == text }.first
    end

    def expect_widget_presence
      expect(page.find('#hbw-tasks-list-button').all('*')).not_to be_empty
    end

    def placeholder(name)
      find_by_name(name)['data-placeholder']
    end

    def label(name)
      page.find("[for='#{name}']").text
    end

    def select2_text_node(name)
      parent_node(page.find("[name='#{name}']")).find('.select2-selection__rendered')
    end

    def select2_cross(name, user_name)
      select2_text_node(name).find("[title='#{user_name}']").find('.select2-selection__choice__remove')
    end

    def select2_id(name)
      parent_node(page.find("[name='#{name}']")).find('.select2-selection__rendered')
    end

    def select2_search_field
      page.find('.select2-search__field')
    end

    def select2_default_text(name)
      select2_text_node(name).text
    end

    def select2_text(name)
      select2_text_node(name).text.sub('×', '')
    end

    def select2_multiple_text(name)
      select2_text_node(name).all('li[title]').map { |node| node.text.sub('×', '') }
    end

    def select2_value(name)
      find_by_name(name).value
    end

    def select_options(name)
      find_by_name(name).all('option[value]', wait: 3).map(&:text)
    end

    def select_values(name)
      find_by_name(name).all('option[value]', wait: 3).map(&:value)
    end

    def select2_options
      parent_node(page.find('.select2-results__option--highlighted')).all('li')
    end

    def change_select2_value(name, value)
      select2_text_node(name).click
      choose_select2_option(value).click
    end

    def choose_select2_option(value)
      select2_options.select { |node| node.text == value }.first
    end

    def success_select_search(name, search)
      select2_text_node(name).find('.select2-search--inline').find('input').set(search)
      select2_options.map(&:text)
    end

    def select2_results
      select2_options.map(&:text)
    end

    def select2_clear_cross(name)
      parent_node(page.find("[name='#{name}']")).find('.select2-selection__clear')
    end

    def select2_no_clear(name)
      expect(parent_node(page.find("[name='#{name}']"))).to have_no_selector('.select2-selection__clear')
    end

    def expect_r_select_presence(name)
      expect(r_select_container(name)).to have_selector('.react-select__input')
    end

    def ensure_r_select_is_empty(name)
      expect(r_select_container(name)).to have_no_selector('.react-select__value-container--has-value')
    end

    def ensure_r_select_unclearable(name)
      expect(r_select_container(name)).to have_no_selector('.react-select__clear-indicator')
    end

    def r_select_container(name)
      page.find("[name='#{name}']", visible: false).ancestor('.react-select-container')
    end

    def r_select_dropdown_indicator(name)
      r_select_container(name).find('.react-select__dropdown-indicator')
    end

    def toggle_r_select_menu(name)
      r_select_dropdown_indicator(name).click
    end

    def set_r_select_option(name, option)
      r_select = r_select_container(name).click

      r_select.find('.react-select__option', text: option).hover
      r_select.find('.react-select__option', text: option).click
    end

    def set_r_select_lookup_option(name, option)
      r_select = r_select_container(name)

      r_select.find('.react-select__option', text: option).hover
      r_select.find('.react-select__option', text: option).click
    end

    def r_select_clear_value(name)
      r_select_container(name).find('.react-select__clear-indicator').click
    end

    def r_select_options(name)
      r_select = r_select_container(name).click

      r_select.all('.react-select__option').map(&:text)
    end

    def r_select_lookup_options(name)
      r_select_container(name).all('.react-select__option').map(&:text)
    end

    def r_select_single_value(name)
      hidden_input = page.find("[name='#{name}']", visible: false)
      r_select = parent_node(hidden_input)

      {
        label: r_select.find('.react-select__single-value').text,
        value: hidden_input.value
      }
    end

    def r_select_placeholder(name, params = {})
      r_select_container(name).find('.react-select__placeholder', **params).text
    end

    def r_select_input(name)
      r_select_container(name).find('.react-select__input')
    end

    def input_by_name(name)
      page.find("input[name='#{name}']")
    end

    def find_by_name(name)
      page.find("[name='#{name}']")
    end

    def calendar_clear_button(name)
      parent_node(input_by_name(name)).find('.fa-trash')
    end

    def calendar_date_button(name)
      parent_node(input_by_name(name)).find('.input-group-addon')
    end

    def parent_node(node)
      node.first(:xpath, './/..')
    end

    def get_datetime_picker_date(name)
      to_current_locale_date(page.evaluate_script("jQuery('[name=\"#{name}\"]').val()"))
    end

    def is_element(name, disabled: false)
      page.evaluate_script("jQuery('[name=\"#{name}\"]#{disabled ? ':disabled' : ''}').length") > 0
    end

    def set_datetime_picker_date(name, date)
      page.execute_script("jQuery('.form-control[name=\"#{name}\"]').parent().data('DateTimePicker').date('#{date}')")
    end

    def calendar_value(name)
      in_current_locale(get_datetime_picker_date(name))
    end

    def in_current_locale(date)
      if date.present?
        date.strftime(datetime_format)
      end
    end

    def to_current_locale_date(date)
      if date.present?
        DateTime.strptime(date, datetime_format)
      end
    end

    def search_button
      find_by_name('commit')
    end

    def empty_order_list
      page.find('.empty-list')
    end

    def orders_list
      page.all(:xpath, '//div[contains(@class, "order-list-table")]/table/tbody/tr').map do |row|
        row.find_all('td').map(&:text)
      end
    end

    def form_by_action(action)
      page.find("[action='#{action}']")
    end

    def search_button_by_action(action)
      form_by_action(action).find('[name="commit"]')
    end

    def click_checkbox_div(class_name)
      page.find("div.#{class_name}").find('label').click
    end

    def click_on_icon(class_name)
      page.find(".#{class_name}").click
    end

    def bp_calendar_value(name)
      page.find("[name='homsOrderData#{name}-visible-input']").value
    end

    def click_on_bp_calendar(name)
      page.find("[name='homsOrderData#{name}-visible-input']").click
    end

    def add_custom_field_filter
      find_by_name('add_custom_field_filter').click
    end

    def click_and_wait(text)
      ajax { click_on(text) }
    end

    def multiselect_by_id(id)
      page.find_by_id(id, visible: false).find(:xpath, '..')
    end

    def multiselect_button_by_id(id)
      multiselect_by_id(id).find(:xpath, '//div[contains(@class, "btn-group")]')
    end

    def click_on_multiselect(id)
      multiselect_button_by_id(id).click
    end

    def checked_multiselect_options(id)
      multiselect_by_id(id).all('li.active input', visible: false).map(&:value)
    end

    def click_on_multiselect_options(id, options)
      click_on_multiselect(id)

      multiselect_by_id(id).all('li').select do |option|
        options.include?(option.find('input', visible: false).value)
      end.map(&:click)

      click_on_multiselect(id)
    end

    def order_list_table_cols
      page.find('.orders-list').all('th').map(&:text)
    end

    def order_list_table_header(column)
      page.find('.order-list-table').all('th').select { |node| node.text == column }.first
    end

    def find_form
      page.find("[class='hbw-form']")
    end

    def find_by_text(text)
      page.find("[text='#{text}']")
    end

    def find_radio_button_variants(name)
      page.all("input[name='#{name}']", visible: false)
    end

    def click_on_radio_button_value(name, value)
      input = find_radio_button_variants(name).select { |node| node.value == value }.first

      parent_node(input).click
    end

    def radio_button_disabled?(name)
      find_radio_button_variants(name).first.disabled?
    end

    def click_on_checkbox_by_name(name)
      input = page.find("input[name='#{name}']", visible: false)

      parent_node(input).click
    end

    def clear_float(str)
      str.to_f.to_s
    end
  end
end
