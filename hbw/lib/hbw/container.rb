require 'dry-container'
require 'dry-auto_inject'

module HBW
  class Container
    extend Dry::Container::Mixin

    register(:api) do
      if Rails.env.test?
        HBW::Activiti::YMLAPI.build(Rails.root.join('hbw/config/yml_api.test.yml'))
      elsif Rails.env.development? && HBW::Widget.config.fetch(:use_activiti_stub)
        HBW::Activiti::YMLAPI.build(Rails.root.join('hbw/config/yml_api.development.yml'))
      else
        HBW::Activiti::API.build
      end
    end

    if Rails.env.test?
      register(:oracle) { HBW::Sources::YMLOracle }
    else
      register(:oracle) { HBW::Sources::Oracle }
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
