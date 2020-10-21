module Features
  module BPFormHelper
    def find_bp_form_with_name(name)
      page.find(:xpath, ".//a[text() = \"#{name}\"]/../../../*//div[contains(@class, 'hbw-form')]")
    end
  end
end
