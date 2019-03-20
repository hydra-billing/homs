module Features
  module TablesHelper
    def click_td_by_text(text)
      page.find('td', text: text).click
    end
  end
end
