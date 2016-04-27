require 'support/helpers/sessions_helper'
require 'support/helpers/orders_helper'
require 'support/helpers/order_types_helper'
require 'support/helpers/users_helper'

FIXTURES_PATH = File.join(__FILE__, '..', '..', '..', 'fixtures')

RSpec.configure do |config|
  config.include(Module.new do
    def fixtures_path(fixture_name)
      File.expand_path(File.join(FIXTURES_PATH, fixture_name.split('/')))
    end

    def fixture(fixture_name)
      File.read(fixtures_path(fixture_name))
    end
  end, type: :feature)

  config.include Features::SessionsHelper,   type: :feature
  config.include Features::OrdersHelper,     type: :feature
  config.include Features::OrderTypesHelper, type: :feature
  config.include Features::UsersHelper,      type: :feature
end
