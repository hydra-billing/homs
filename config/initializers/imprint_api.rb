require 'dry-container'
require 'dry-auto_inject'
require 'imprint/yml_api'
require 'imprint/wrapper'

Rails.application.config.to_prepare do

  container = Dry::Container.new

  if Rails.env.test?
    container.register(:imprint_api, -> { Imprint::YMLAPI.build })
  else
    Imprint::API.load(%w(config/imprint.default.yml
                         config/imprint.yml))
    container.register(:imprint_api, -> { Imprint::API.build })
  end

  container.register(:imprint_adapter, -> { Imprint::Adapter.new })

  Imprint::Wrapper.container = container
  Imprint::Wrapper.inject    = Dry::Injection.new(container, {type: :hash})
end
