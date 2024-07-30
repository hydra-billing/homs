require_relative 'boot'

require 'rails'
require 'active_record/railtie'
require 'action_cable/engine'

require 'dry-container'
require 'dry-validation'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HOMS
  class Application < Rails::Application
    VERSION = '2.7.0'.freeze

    config.generators do |g|
      g.test_framework :rspec,
                       fixtures:         true,
                       view_specs:       false,
                       helper_specs:     false,
                       routing_specs:    false,
                       controller_specs: false,
                       request_specs:    false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Moscow'

    config.load_defaults 7.0

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    initializer('homs.load_container') do
      require 'container'
    end

    config.allow_concurrency = true

    config.action_controller.permit_all_parameters = true

    config.action_controller.per_form_csrf_tokens = true

    # Allow to serialize Symbol
    config.active_record.yaml_column_permitted_classes = [Symbol]

    require Rails.root.join('lib/homs_config')
    config.app = Settings::Homs

    redis_config = config.app.fetch(:redis, {})
    config.cache_store = :redis_cache_store, {url: "redis://#{redis_config.fetch(:host)}:#{redis_config.fetch(:port)}/0"}

    config.active_record.belongs_to_required_by_default = false

    require Rails.root.join('lib/imprint')

    config.relative_url_root = config.app.fetch(:base_url, '/')

    config.after_initialize do
      HOMS.container[:cef_logger].log_event(:start)

      locale = config.app.fetch(:locale, {})

      I18n.locale = I18n.default_locale = (locale.fetch(:code) || :en).to_sym
    end

    require Rails.root.join('lib/datetime_format')
  end
end
