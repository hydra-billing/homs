require 'dry-container'
require 'dry-auto_inject'
require 'dry/container/stub'
require 'cef_logger'

module HOMS
  class Container
    extend Dry::Container::Mixin

    register(:cef_logger) { CEFLogger.new(enabled: Rails.application.config.app.fetch(:cef_logger, false)) }
  end

  Inject = Dry::AutoInject(Container)

  def self.container
    Container
  end

  def self.inject
    Inject
  end
end
