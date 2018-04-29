$:.push File.expand_path('../lib', __FILE__)

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

  s.files = Dir['{app,config,db,lib}/**/*']

  s.add_dependency 'rails', '~> 4.2.10'
  s.add_dependency 'coffee-rails', '~> 4.1'
  s.add_dependency 'faraday'
  s.add_dependency 'faraday_middleware'
  s.add_dependency 'faraday-detailed_logger'
end
