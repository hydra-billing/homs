require 'dry-container'
require 'dry-auto_inject'

module HBW
  class Container
    extend Dry::Container::Mixin

    if Rails.env.test?
      register(:api) { HBW::Activiti::YMLAPI.build }
    else
      register(:api) { HBW::Activiti::API.build }
    end

    register(:adapter) { HBW::Activiti::Adapter.new }

    register(:config) { HBW::Widget.config }
  end

  Inject = Dry::AutoInject(Container)

  def self.container
    Container
  end

  def self.inject
    Inject
  end
end
