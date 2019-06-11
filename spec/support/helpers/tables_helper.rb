module Features
  module TablesHelper
    def set_select_table_option(text)
      page.find('td', text: text).click
    end
  end
end
