require_relative './minio/container'
module Minio
  Import = Dry::AutoInject(Container)

  class << self
    def inject(target)
      -> *values { target.send(:include, Import[*values]) }
    end
  end

  module Mixin
    def container
      Minio::Container
    end

    def inject
      Minio.inject(self)
    end
  end
end
