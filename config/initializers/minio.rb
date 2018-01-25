require 'aws-sdk'

Rails.application.config.to_prepare do
  config = Rails.application.config.app.fetch(:minio, {})
  unless config.empty?
    Aws.config.update(
      endpoint: config[:endpoint],
      credentials: Aws::Credentials.new(
          config[:access_key_id],
          config[:secret_access_key]),
      force_path_style: true,
      region: config[:region])
  end
end
