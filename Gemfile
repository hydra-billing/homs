source 'https://rubygems.org'
ruby '2.2.4'
gem 'rails', '~> 4.2.1'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jbuilder', '~> 2.0'
gem 'coderay', '~> 1.1'
gem 'kaminari', '~> 0.16'  # adds pagination to ActiveModels
gem 'bootstrap-sass'
gem 'devise'
gem 'haml-rails'
gem 'pg'
gem 'simple_form'
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.7.14'
gem 'modulejs-rails'
gem 'react-rails', '~> 1.0'
gem 'font-awesome-rails'
gem 'bootswatch-rails'
gem 'pry-rails'
gem 'i18n-js', github: 'fnando/i18n-js'
gem 'twitter-bootstrap-rails-confirm'
gem 'hbw', path: File.join(File.dirname(__FILE__), 'hbw')
gem 'asset_symlink'
gem 'apitome'
gem 'dry-container'
gem 'dry-auto_inject'
gem 'thin'

group :oracle do
  gem 'ruby-oci8', '2.2.1'
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
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'spring-commands-rspec'
  gem 'ruby_parser'
end

group :development, :test, :staging do
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rspec-mocks'
  gem 'translit'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'rspec_api_documentation', '~> 4.4'
  gem 'raddocs', '~> 0.4'
  gem 'rubocop'
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
  gem 'database_cleaner'
  gem 'launchy'
  gem 'poltergeist'
  gem 'capybara-screenshot'
end
