require File.expand_path('../boot', __FILE__)

require 'rails/all'

require 'dry-container'
require 'dry-auto_inject'
require 'dry-validation'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Homs
  class Application < Rails::Application

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Moscow'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.asset_symlink = %w(hbw.css)

    config.allow_concurrency = true

    config.action_controller.permit_all_parameters = true

    config.cache_store = :dalli_store, ENV['MEMCACHED_URL'] || '127.0.0.1'

    require Rails.root.join('lib/homs_config')
    config.app = HomsConfig.load(%w(config/homs_configuration.default.yml
                                    config/homs_configuration.yml))

    require Rails.root.join('lib/imprint')

    config.relative_url_root = config.app.fetch(:base_url, '/')

    config.after_initialize do
      I18n.locale = I18n.default_locale = (config.app.locale.fetch(:code) || :en).to_sym
    end

    require Rails.root.join('lib/datetime_format')
  end
end
