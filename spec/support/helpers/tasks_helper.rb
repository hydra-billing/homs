Capybara.add_selector(:dt) do
  css { |value| "*[data-test=#{value}]" }
end

Capybara.add_selector(:dp) do
  css { |value| "*[data-prefix=#{value}]" }
end

Capybara.add_selector(:di) do
  css { |value| "*[data-icon=#{value}]" }
end

module Features
  module TasksHelper
    def find_by_dt(value, context = page)
      context.find(:dt, value)
    end

    def miss_by_dt(value, context = page)
      context.find(:dt, value, wait: 0.1)
    rescue Capybara::ElementNotFound
      true
    end

    def tasks_counter
      page.find('#hbw-tasks-list-button')
    end

    def tasks_count
      tasks_counter.text
    end

    def click_on_tasks_counter
      tasks_counter.click
    end

    def popup_tasks_list
      page.find('div', class: 'claimimg-popup').all('div', class: 'row')
    end

    def popup_tasks_list_content
      popup_tasks_list.map(&:text)
    end

    def click_on_task_list_row(row_number)
      popup_tasks_list[row_number - 1].click
    end

    def tasks_table
      page.find('div', class: 'claiming-table')
    end

    def tasks_table_header
      tasks_table.all('th').map(&:text)
    end

    def tasks_table_content
      tasks_table.all('tr').to_a[1..].map { |row| row.all('td').map(&:text) }
    end

    def click_on_tab(text)
      page.find('a', class: 'tab', text: text).click
    end

    def claim_task(row_number)
      ajax { tasks_table.all('tr')[row_number].find('td', text: 'Claim').click }
    end

    def check_row_is_claiming(row_number)
      tasks_table.all('tr')[row_number].has_css?('.claiming')
    end

    def check_row_is_not_claiming(row_number)
      tasks_table.all('tr')[row_number].has_no_css?('.claiming')
    end

    def click_on_task_table_row(row_number)
      ajax { tasks_table.all('tr')[row_number].click }
    end

    def fill_search_field(text)
      find('.search-input-with-controls').find('input').set(text)
    end

    def search_field_text
      find('.search-input-with-controls').find('input').value
    end

    def clear_search_field
      find('.search-input-with-controls').find('.cross').click
    end

    def confirm_dialog_box
      ajax { page.driver.browser.switch_to.alert.accept }
    end

    def years_since(date)
      ((DateTime.now.in_time_zone - date) / 1.year).floor
    end

    def readonly?(name)
      find_by_name(name).readonly?
    end
  end
end
