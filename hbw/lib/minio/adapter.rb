require 'aws-sdk'

module Minio
  class Adapter
    extend Imprint::Mixin

    def save_file(files)
      result = []
      unless files.nil?
        files.each do |file|
          s3 = Aws::S3::Resource.new(Aws::S3::Client.new)
          bucket = s3.bucket(HBW::Widget.config[:minio][:bucket])
          file_name = "#{DateTime.now.strftime('%Q').to_i}_#{file['name']}"
          obj = bucket.object(file_name)
          obj.put(body: Base64.decode64(file['content']))

          result.push({url: obj.public_url, name: file_name})
        end
      end

      result
    end
  end
end
