module Imprint
  class Container
    extend Dry::Container::Mixin

    @root = Pathname(__FILE__).realpath.dirname
    singleton_class.send(:attr_reader, :root)

    if Rails.env.test?
      register(:imprint_api) do
        require "#{root}/yml_api.rb"

        Imprint::YMLAPI.build
      end
    else
      register(:imprint_api) do
        Imprint::API.load
        Imprint::API.build
      end
    end

    register(:imprint_adapter) do
      Imprint::Adapter.new
    end

    register('services.order_printing_service') do
      require "#{root}/services/order_printing_service.rb"

      Imprint::Services::OrderPrintingService.new
    end
  end
end
