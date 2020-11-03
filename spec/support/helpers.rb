require 'support/helpers/sessions_helper'
require 'support/helpers/orders_helper'
require 'support/helpers/tables_helper'
require 'support/helpers/tasks_helper'
require 'support/helpers/order_types_helper'
require 'support/helpers/users_helper'
require 'support/helpers/wait_for_ajax_helper'
require 'support/helpers/bp_form_helper'
require 'support/helpers/i18n_helper'

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

  config.include Features::SessionsHelper,    type: :feature
  config.include Features::OrdersHelper,      type: :feature
  config.include Features::OrderTypesHelper,  type: :feature
  config.include Features::TablesHelper,      type: :feature
  config.include Features::TasksHelper,       type: :feature
  config.include Features::UsersHelper,       type: :feature
  config.include Features::WaitForAjaxHelper, type: :feature
  config.include Features::BPFormHelper,      type: :feature
  config.include Features::I18nHelper,        type: :feature
end
