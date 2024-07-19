$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'hbw/version'

Gem::Specification.new do |s|
  rails_version = '7.1.3.4'

  s.name        = 'hbw'
  s.version     = HBW::VERSION
  s.authors     = ['Nikita Shilnikov']
  s.email       = ['ns@latera.ru']
  s.homepage    = 'http://github.com/latera/hbw'
  s.summary     = 'HBW'
  s.description = '...'
  s.license     = 'Commercial'
  s.required_ruby_version = '~> 3.2'

  s.files = Dir['{app,config,db,lib}/**/*']

  s.add_dependency 'actionpack', "~> #{rails_version}"
  s.add_dependency 'actionview', "~> #{rails_version}"
  s.add_dependency 'activemodel', "~> #{rails_version}"
  s.add_dependency 'activerecord', "~> #{rails_version}"
  s.add_dependency 'activesupport', "~> #{rails_version}"
  s.add_dependency 'coffee-rails'
  s.add_dependency 'faraday'
  s.add_dependency 'faraday-detailed_logger'
  s.add_dependency 'faraday_middleware'
  s.add_dependency 'railties', "~> #{rails_version}"
end
