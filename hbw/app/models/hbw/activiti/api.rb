require 'faraday/detailed_logger'
require 'faraday_middleware'

module HBW
  module Activiti
    class API
      class_attribute :config
      attr_reader :token

      def initialize(conn, api_token)
        @conn = conn
        @token = api_token
      end

      %w(get put patch post delete).each do |method|
        define_method method do |url, *params|
          @conn.send(method, url, *params) do |request|
            request.headers['Content-type'] = 'application/json'
            request.headers['Authorization'] = "Basic #{token}"
          end
        end
      end

      class << self
        include HBW::Logger

        def build(config = API.config)
          conn = Faraday.new(url: config[:base_url]) do |faraday|
            faraday.request :json
            faraday.response :json, content_type: /\bjson$/
            faraday.response :detailed_logger, logger
            faraday.adapter Faraday.default_adapter
          end

          new(conn, config[:api_token] || token_from(config[:login], config[:password]))
        end

        def token_from(login, password)
          Base64.strict_encode64 "#{login}:#{password}"
        end
      end
    end
  end
end
