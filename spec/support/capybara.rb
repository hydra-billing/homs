Capybara.asset_host = 'http://localhost:3000'
Capybara.javascript_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
Capybara.automatic_reload = false
Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  "screenshot_#{example.full_description.gsub(' ', '-').gsub(/^.*\/spec\//,'')}"
end
