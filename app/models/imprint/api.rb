require 'faraday/detailed_logger'
require 'faraday_middleware'
require 'settings'

module Imprint
  class API
    class_attribute :config

    def initialize(conn)
      @conn = conn
    end

    %w(get put patch post delete).each do |method|
      define_method method do |url, *params|
        @conn.send(method, url, *params) do |request|
          request.headers['Content-type']          = 'application/json'
          request.headers['X_IMPRINT_API_VERSION'] = config[:api_version]
          request.headers['Accept']                = 'application/json'
          request.headers['X_IMPRINT_API_TOKEN']   = config[:auth_token]
        end
      end
    end

    class << self
      def build(config = API.config)
        conn = Faraday.new(url: config[:base_url]) do |faraday|
          faraday.request  :json
          faraday.response :json, content_type: /\bjson$/
          faraday.response :detailed_logger, Rails.logger
          faraday.adapter  Faraday.default_adapter
        end

        new(conn)
      end

      def load
        Imprint::API.config = Settings::Imprint[Rails.env].deep_symbolize_keys
      end
    end
  end
end
