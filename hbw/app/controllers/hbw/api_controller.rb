require 'dry-effects'

module HBW
  class APIController < BaseController
    include Dry::Effects::Handler.Reader(:auth_header)

    rescue_from HBW::Remote::RemoteError do |exception|
      render json: exception.to_s.force_encoding('utf-8').to_json, status: 504
    end

    around_action :provide_auth_header

    private

    def provide_auth_header(&)
      with_auth_header(auth_header, &)
    end

    def auth_header
      if sso_enabled?
        "Bearer #{@access_token}"
      else
        "Basic #{basic_auth_token}"
      end
    end

    def basic_auth_token
      Base64.strict_encode64 "#{bpm_config.fetch(:login)}:#{bpm_config.fetch(:password)}"
    end
  end
end
