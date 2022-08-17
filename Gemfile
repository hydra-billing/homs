source 'https://rubygems.org'

ruby '2.7.6'

gem 'apitome'
gem 'aws-sdk-s3'
gem 'coderay', '~> 1.1'
gem 'coffee-rails', '~> 4.2'
gem 'dalli'
gem 'devise'
gem 'devise-encryptable'
gem 'dry-auto_inject'
gem 'dry-container'
gem 'dry-monads'
gem 'dry-struct'
gem 'dry-validation'
gem 'haml-rails'
gem 'hbw', path: File.join(File.dirname(__FILE__), 'hbw')
gem 'hydra-keycloak-client'
gem 'i18n-js', git: 'https://github.com/fnando/i18n-js', ref: '7ed2d2'
gem 'jbuilder', '~> 2.10'
gem 'jwt'
gem 'kaminari'
gem 'minipack'
gem 'modulejs-rails'
gem 'momentjs-rails', '>= 2.9.0'
gem 'pg', '0.20'
gem 'pry-rails'
gem 'rack', '~> 2.2.3'
gem 'rails', '~> 5.2.4'
gem 'redis'
gem 'settingslogic'
gem 'simple_form'
gem 'sprockets', '~> 3.7'

group :oracle do
  gem 'ruby-oci8', '2.2.3'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'html2haml'
  gem 'rails_layout'
  gem 'ruby_parser'
  gem 'spring-commands-rspec'
end

group :development, :test, :staging do
  gem 'factory_bot_rails', '~> 4.8.2'
  gem 'faker'
  gem 'pry-byebug'
  gem 'rspec_api_documentation', '~> 4.4'
  gem 'rspec_junit_formatter'
  gem 'rspec-mocks'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'spring'
  gem 'translit'
end

group :development, :test do
  gem 'puma'
end

group :production, :staging do
  gem 'unicorn'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'temping'
end
