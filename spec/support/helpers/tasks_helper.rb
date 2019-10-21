module Features
  module TasksHelper
    def tasks_count
      page.find('#hbw-tasks-list-button').text
    end

    def tasks_table
      page.find('div', class: 'claiming-table')
    end

    def tasks_table_header
      tasks_table.all('th').map(&:text)
    end

    def tasks_table_content
      tasks_table.all('tr')[1..-1].map { |row| row.all('td').map(&:text) }
    end

    def click_on_tab(text)
      page.find('a', class: 'tab', text: text).click
      wait_for_ajax
    end

    def claim_task(row_number)
      tasks_table.all('tr')[row_number].find('td', text: 'Claim').click
    end

    def check_row_is_claiming(row_number)
      tasks_table.all('tr')[row_number].has_css?('.claiming')
    end

    def check_row_is_not_claiming(row_number)
      tasks_table.all('tr')[row_number].has_no_css?('.claiming')
    end
  end
end
