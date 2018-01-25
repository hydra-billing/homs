require 'aws-sdk'

module Minio
  class Adapter
    extend Imprint::Mixin

    def save_file(file, order_id)
      s3 = Aws::S3::Resource.new(Aws::S3::Client.new)
      bucket = s3.bucket(Rails.application.config.app[:minio][:bucket])
      obj = bucket.object(file[:name])
      obj.put(body: Base64.decode64(file[:content]))

      attachment = Attachment.new(url: obj.public_url,
                                  order_id: order_id,
                                  name: file[:name])

      attachment.save
    end
  end
end
