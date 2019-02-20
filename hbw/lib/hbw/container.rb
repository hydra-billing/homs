require 'dry-container'
require 'dry-auto_inject'

module HBW
  class Container
    extend Dry::Container::Mixin

    register(:api) do
      if Rails.env.test?
        HBW::Camunda::YMLAPI.build(Rails.root.join('hbw/config/yml_api.test.camunda.yml'))
      elsif Rails.env.development? && HBW::Widget.config.fetch(:use_bpm_stub)
        HBW::Camunda::YMLAPI.build(Rails.root.join('hbw/config/yml_api.development.yml'))
      else
        HBW::Camunda::API.build
      end
    end

    if Rails.env.test?
      register(:oracle) { HBW::Sources::YMLOracle }
    else
      register(:oracle) { HBW::Sources::Oracle }
    end

    register(:adapter) do
      HBW::Camunda::Adapter.new
    end

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
