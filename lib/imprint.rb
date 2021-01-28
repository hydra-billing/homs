require_relative './imprint/container'

module Imprint
  Import = Dry::AutoInject(Container)

  class << self
    def inject(target)
      ->(*values) { target.send(:include, Import[*values]) }
    end
  end

  module Mixin
    def container
      Imprint::Container
    end

    def inject
      Imprint.inject(self)
    end
  end
end
