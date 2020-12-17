Capybara.register_driver :chrome do |app|
  Selenium::WebDriver::Chrome::Service.driver_path = '/usr/local/bin/chromedriver'

  opts = Selenium::WebDriver::Chrome::Options.new

  chrome_args = %w[--headless --window-size=1920,1080 --no-sandbox --disable-dev-shm-usage]
  chrome_args.each { |arg| opts.add_argument(arg) }

  opts.add_preference(:download,
                      directory_upgrade: true,
                      prompt_for_download: false,
                      default_directory: DownloadHelper::PATH.to_s)

  opts.add_preference(:browser, set_download_behavior: { behavior: 'allow' })

  driver = Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 options: opts)

  # https://bugs.chromium.org/p/chromium/issues/detail?id=696481#c89
  bridge = driver.browser.send(:bridge)
  path = "/session/#{bridge.session_id}/chromium/send_command"

  bridge.http.call(:post, path, cmd: 'Page.setDownloadBehavior',
                   params: {
                       behavior: 'allow',
                       downloadPath: DownloadHelper::PATH.to_s
                   })

  driver
end

Capybara.asset_host = 'http://localhost:3000'
Capybara.javascript_driver = :chrome
Capybara.automatic_reload = false

Capybara::Screenshot.register_driver(:chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  "screenshot_#{example.full_description.gsub(' ', '-').gsub(/^.*\/spec\//,'')}"
end
Capybara.default_max_wait_time = 10
Capybara.server = :puma
