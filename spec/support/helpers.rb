require 'support/helpers/sessions_helper'
require 'support/helpers/orders_helper'
require 'support/helpers/tables_helper'
require 'support/helpers/tasks_helper'
require 'support/helpers/order_types_helper'
require 'support/helpers/users_helper'
require 'support/helpers/wait_for_ajax_helper'
require 'support/helpers/bp_form_helper'
require 'support/helpers/i18n_helper'
require 'support/helpers/files_helper'
require 'support/helpers/scopes_helper'

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

  [
    Features::SessionsHelper,
    Features::OrdersHelper,
    Features::OrderTypesHelper,
    Features::TablesHelper,
    Features::TasksHelper,
    Features::UsersHelper,
    Features::WaitForAjaxHelper,
    Features::BPFormHelper,
    Features::I18nHelper,
    Features::FilesHelper,
    Features::ScopesHelper
  ].each { |helper| config.include(helper, type: :feature) }
end
