module HBW
  class ApiController < BaseController
    rescue_from HBW::Remote::RemoteError do |exception|
      render json: exception.to_s.force_encoding('utf-8').to_json, status: 504
    end
  end
end
