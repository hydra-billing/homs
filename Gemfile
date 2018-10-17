source 'https://rubygems.org'
ruby '2.5.1'
gem 'rails', '~> 5.1.6'
gem 'sass-rails', '~> 5.0.7'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jbuilder', '~> 2.0'
gem 'coderay', '~> 1.1'
gem 'kaminari', '~> 0.16'  # adds pagination to ActiveModels
gem 'bootstrap-sass'
gem 'devise'
gem 'devise-encryptable'
gem 'haml-rails'
gem 'pg', '0.20'
gem 'simple_form'
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.7.14'
gem 'modulejs-rails'
gem 'react-rails', '~> 1.0'
gem 'font-awesome-rails'
gem 'bootswatch-rails'
gem 'pry-rails'
gem 'i18n-js', git: 'https://github.com/fnando/i18n-js', ref: '7ed2d2'
gem 'twitter-bootstrap-rails-confirm'
gem 'hbw', path: File.join(File.dirname(__FILE__), 'hbw')
gem 'asset_symlink'
gem 'apitome'
gem 'dry-container'
gem 'dry-auto_inject'
gem 'dry-validation'
gem 'thin'
gem 'nokogiri', '~> 1.8.1'
gem 'aws-sdk', '~> 2'
gem 'web-console', '~> 2.0', group: :development
gem 'settingslogic'

group :oracle do
  gem 'ruby-oci8', '2.2.3'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano', '~> 3.1'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-postgresql'
  gem 'capistrano-rails-console'
  gem 'capistrano-db-tasks', require: false
  gem 'capistrano-rvm', '~> 0.1.1'
  gem 'html2haml'
  gem 'rails_layout'
  gem 'spring-commands-rspec'
  gem 'ruby_parser'
end

group :development, :test, :staging do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rspec-mocks'
  gem 'translit'
  gem 'spring'
  gem 'rspec_api_documentation', '~> 4.4'
  gem 'rubocop', '~> 0.49.0'
  gem 'debbie'
  gem 'pry-byebug'
  gem 'rspec_junit_formatter'
end

group :production, :staging do
  gem 'unicorn'
end

group :test do
  gem 'temping'
  gem 'capybara'
  gem 'capybara-webkit', github: 'thoughtbot/capybara-webkit', branch: 'master'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'capybara-screenshot'
end
