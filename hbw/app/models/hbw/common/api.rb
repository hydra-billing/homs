require 'dry-effects'
require 'faraday/detailed_logger'
require 'faraday_middleware'
require 'settings'

module HBW
  module Common
    class API
      include Dry::Effects.Reader(:auth_header)

      class_attribute :config

      attr_reader :process_keys

      def initialize(conn, process_keys)
        @conn = conn
        @process_keys = process_keys
      end

      %w(get put patch post delete).each do |method|
        define_method method do |url, *params|
          @conn.send(method, url, *params)
        end
      end

      def process_supported?(key)
        process_keys.include?(key)
      end

      class << self
        include HBW::Logger
        include Dry::Effects.Reader(:auth_header)

        def build(bpm_config)
          conn = Faraday.new(url: bpm_config[:url]) do |faraday|
            faraday.request :json
            faraday.headers['Content-type'] = 'application/json'
            faraday.headers['Authorization'] = auth_header.(bpm_config[:login], bpm_config[:password])
            faraday.response :json, content_type: /\bjson$/
            faraday.response :detailed_logger, logger
            faraday.adapter Faraday.default_adapter
          end

          new(conn, bpm_config[:process_keys])
        end
      end
    end
  end
end
