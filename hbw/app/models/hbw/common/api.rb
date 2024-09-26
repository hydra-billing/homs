require 'dry-effects'
require 'faraday/detailed_logger'
require 'faraday_middleware'
require 'settings'

module HBW
  module Common
    class API
      include Dry::Effects.Reader(:auth_header)

      class_attribute :config

      def initialize(conn)
        @conn = conn
      end

      %w(get put patch post delete).each do |method|
        define_method method do |url, *params|
          @conn.send(method, url, *params) do |request|
            request.headers['Content-type'] = 'application/json'
            request.headers['Authorization'] = auth_header
          end
        end
      end

      class << self
        include HBW::Logger

        def build
          conn = Faraday.new(url: config.first[:url]) do |faraday|
            faraday.request :json
            faraday.response :json, content_type: /\bjson$/
            faraday.response :detailed_logger, logger
            faraday.adapter Faraday.default_adapter
          end

          new(conn)
        end
      end
    end
  end
end
