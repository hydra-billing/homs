require 'faraday/detailed_logger'
require 'faraday_middleware'

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

      def load(paths)
        paths.map! { |path| Rails.root.join(path) }

        configs = paths.select { |p| File.exists?(p) && File.read(p).present? }.map { |p| YAML.load(File.read(p))[Rails.env] || {} }
        Imprint::API.config = configs.reduce(:deep_merge).deep_symbolize_keys
      end
    end
  end
end
