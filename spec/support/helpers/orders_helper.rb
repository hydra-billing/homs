module Features
  module OrdersHelper
    def click_on_calendar(class_name)
      page.find(".#{class_name} .input-group-addon").click
      page.find('nav').click
    end

    def set_date(class_name, day)
      page.find(".#{class_name} .fa-calendar").click
      expect(page.find(".#{class_name} .day", :text => "#{day}").text).to have_content(day)
      page.find(".#{class_name} .day", :text => "#{day}").click
      page.find('nav').click
    end

    def header
      page.find('h2')
    end

    def find_by_title(title)
      page.find("[title='#{title}']")
    end

    def active_tab(text)
      page.all('li.active').find{ |node| node.find('a', text: text) }
    end

    def tab(text)
      page.all('a[data-toggle="tab"]').select{|x| x.text == text}.first
    end

    def input_by_placeholder(placeholder)
      page.find("input[placeholder='#{placeholder}']")
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
      select2_text_node(name).all('li[title]').map{|node| node.text.sub('×', '')}
    end

    def select2_value(name)
      find_by_name(name).value
    end

    def select_options(name)
      find_by_name(name).all('option[value]').map(&:text)
    end

    def select_values(name)
      find_by_name(name).all('option[value]').map(&:value)
    end

    def select2_options
      parent_node(page.find('.select2-results__option--highlighted')).all('li')
    end

    def change_select2_value(name, value)
      select2_text_node(name).click
      choose_select2_option(value).click
    end

    def choose_select2_option(value)
      select2_options.select{|node| node.text == value}.first
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

    def input_by_name(name)
      page.find("input[name='#{name}']")
    end

    def find_by_name(name)
      page.find("[name='#{name}']")
    end

    def calendar_clear_button(name)
      parent_node(input_by_name(name)).find('.glyphicon-trash')
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

    def set_datetime_picker_date(name, date)
      page.execute_script("jQuery('.form-control[name=\"#{name}\"]').parent().data('DateTimePicker').date('#{date}')")
    end

    def calendar_value(name)
      in_current_locale(get_datetime_picker_date(name))
    end

    def in_current_locale(date)
      if date.present?
        date.strftime(I18n.t('time.formats.datetime'))
      end
    end

    def to_current_locale_date(date)
      if date.present?
        DateTime.strptime(date, I18n.t('time.formats.datetime'))
      end
    end

    def search_button
      find_by_name('commit')
    end

    def empty_order_list
      page.find('.empty-list')
    end

    def orders_list
      page.find('.orders-list').all('tr').map do |row|
        row.all('td').map(&:text)
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
      page.find("[name='homsOrderData#{name}']").value
    end

    def click_on_bp_calendar(name)
      page.find("[name='homsOrderData#{name}']").find(:xpath, '..').find('span.fa.fa-calendar').click
    end

    def add_custom_field_filter
      find_by_name('add_custom_field_filter').click
    end

    def click_and_wait(text)
      click_on(text)
      wait_for_ajax
    end
  end
end
