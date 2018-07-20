Capybara.asset_host = 'http://localhost:3000'
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, port: 3001)
end
Capybara.javascript_driver = :poltergeist
Capybara.automatic_reload = false
Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  "screenshot_#{example.full_description.gsub(' ', '-').gsub(/^.*\/spec\//,'')}"
end
Capybara.default_max_wait_time = 10
Capybara.server = :webrick
