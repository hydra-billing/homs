module Features
  module ScopesHelper
    def in_group_with_label(group_label)
      tab_selector = "//a[text() = '#{group_label}']"
      closest_tab_panel = "ancestor::div[contains(@class, 'tab-panel') and position() = 1]"
      group = page.find(:xpath, "#{tab_selector}/#{closest_tab_panel}")
      yield(group)
    end
  end
end
