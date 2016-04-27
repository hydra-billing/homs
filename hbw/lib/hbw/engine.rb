require 'dry-container'
require 'dry-auto_inject'

module HBW
  mattr_accessor :container, :inject

  class Engine < ::Rails::Engine
    isolate_namespace HBW

    config.to_prepare do
      container = Dry::Container.new

      if Rails.env.test?
        container.register(:activiti_api, HBW::Activiti::YMLAPI.build)
      else
        container.register(:activiti_api, -> { HBW::Activiti::API.build })
      end

      container.register(:adapter_class, -> { HBW::Activiti::Adapter })

      HBW.container = container

      HBW.inject = Dry::Injection.new(container, {type: :hash})
    end
  end
end

require 'hbw/config'
