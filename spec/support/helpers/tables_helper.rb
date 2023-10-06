module Features
  module TablesHelper
    def click_on_select_table_option(text)
      page.find('td', text:).click
    end

    def selected_options
      page.all('.selected').map { |el| el.all('td').first.text }.sort
    end

    def table_options
      page.find('table.select-table')
          .all(:xpath, './tbody/tr')
          .map { |el| el.all('td').first.text }
          .sort
    end

    def selected_options_in_table_with_label(label)
      page.find('span.select-table-label', exact_text: label)
          .sibling('div.hbw-table')
          .all('.selected')
          .map { |el| el.all('td').first.text }
          .sort
    end

    def options_in_table_with_label(label)
      page.find('span.select-table-label', exact_text: label)
          .sibling('div.hbw-table')
          .find('table.select-table')
          .all(:xpath, './tbody/tr')
          .map { |el| el.all('td').first.text }
          .sort
    end
  end
end
