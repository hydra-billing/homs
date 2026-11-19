# frozen_string_literal: true

require 'capybara/selenium/driver'

# Workaround for Chrome 158, which rejects the "*" origin that Capybara passes
# to Storage.clearDataForOrigin at the end of every session reset. Without it
# every test that uses the browser fails in the reset with
# "invalid argument: * is not a valid URL"
# (https://github.com/teamcapybara/capybara/issues/2865).
#
# Cookies are still cleared for every origin. Local storage is cleared for the
# application origin only: Chrome has no command that clears it everywhere.
module CapybaraChromeResetPatch
  private

  def execute_cdp(cmd, params = {})
    return super unless cmd == 'Storage.clearDataForOrigin' && params[:origin] == '*'

    storage_types = params[:storageTypes].to_s.split(',')
    super('Network.clearBrowserCookies') if storage_types.delete('cookies')
    origin = application_origin
    return if storage_types.empty? || origin.nil?

    super(cmd, params.merge(origin: origin, storageTypes: storage_types.join(',')))
  end

  # The origin of the Capybara server this driver belongs to. Looked up in the
  # session pool without creating sessions, since reset_sessions! iterates it.
  def application_origin
    return Capybara.app_host if Capybara.app_host

    session = Capybara.send(:session_pool).values.find { |s| s.instance_variable_get(:@driver).equal?(self) }
    session&.server&.base_url
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(CapybaraChromeResetPatch)
