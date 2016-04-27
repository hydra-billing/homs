Capybara.asset_host = 'http://localhost:3000'
Capybara.default_driver = :webkit
Capybara.javascript_driver = :webkit
Capybara.automatic_reload = false
Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  "screenshot_#{example.full_description.gsub(' ', '-').gsub(/^.*\/spec\//,'')}"
end
