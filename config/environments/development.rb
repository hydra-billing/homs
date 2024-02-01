Rails.application.configure do
  config.hosts = [
    IPAddr.new('127.0.0.1'),
    'host.docker.internal'
  ]
  # Settings specified here will take precedence over those in
  # config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for
  # development since you don't have to restart the web server when you
  # make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  config.public_file_server.enabled = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  require 'homs_logger'

  config.logger = HomsLogger.new(ActiveSupport::Logger.new($stdout))

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.i18n.default_locale = :en
end
