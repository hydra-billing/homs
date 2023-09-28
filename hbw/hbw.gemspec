$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'hbw/version'

Gem::Specification.new do |s|
  s.name        = 'hbw'
  s.version     = HBW::VERSION
  s.authors     = ['Nikita Shilnikov']
  s.email       = ['ns@latera.ru']
  s.homepage    = 'http://github.com/latera/hbw'
  s.summary     = 'HBW'
  s.description = '...'
  s.license     = 'Commercial'
  s.required_ruby_version = '~> 2.7'

  s.files = Dir['{app,config,db,lib}/**/*']

  s.add_dependency 'actionpack', '~> 6.1.7'
  s.add_dependency 'actionview', '~> 6.1.7'
  s.add_dependency 'activemodel', '~> 6.1.7'
  s.add_dependency 'activerecord', '~> 6.1.7'
  s.add_dependency 'activesupport', '~> 6.1.7'
  s.add_dependency 'coffee-rails'
  s.add_dependency 'faraday'
  s.add_dependency 'faraday-detailed_logger'
  s.add_dependency 'faraday_middleware'
  s.add_dependency 'railties', '~> 6.1.7'
end
