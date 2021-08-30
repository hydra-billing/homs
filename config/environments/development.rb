Rails.application.configure do
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

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               Rails.application.secrets.domain_name,
    authentication:       'plain',
    enable_starttls_auto: true,
    user_name:            Rails.application.secrets.email_provider_username,
    password:             Rails.application.secrets.email_provider_password
  }
  # ActionMailer Config
  config.action_mailer.default_url_options = {host: 'localhost:3000'}
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  # Send email in development mode?
  config.action_mailer.perform_deliveries = true

  require 'homs_logger'

  config.logger = HomsLogger.new(ActiveSupport::Logger.new($stdout))

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.i18n.default_locale = :en
end
