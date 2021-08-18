require 'dry-container'
require 'dry-auto_inject'
require 'dry/container/stub'

module HBW
  class Container
    extend Dry::Container::Mixin

    register(:api) do
      if Rails.env.development? && HBW::Widget.config.fetch(:use_bpm_stub)
        HBW::Camunda::YMLAPI.build('hbw/config/yml_api.development.yml')
      else
        HBW::Camunda::API.build
      end
    end

    register(:oracle) do
      if Rails.env.test?
        HBW::Sources::YMLOracle
      else
        HBW::Sources::Oracle
      end
    end

    if Rails.env.test?
      enable_stubs!
    end

    register(:adapter) { HBW::Camunda::Adapter.new }
    register(:config)  { HBW::Widget.config }
  end

  Inject = Dry::AutoInject(Container)

  def self.container
    Container
  end

  def self.inject
    Inject
  end
end
