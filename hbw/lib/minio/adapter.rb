require 'aws-sdk'

module Minio
  class Adapter
    extend Imprint::Mixin

    def save_file(files)
      result = []
      s3 = Aws::S3::Resource.new(Aws::S3::Client.new)
      bucket = s3.bucket(HBW::Widget.config[:minio][:bucket])

      unless files.nil?
        files.each do |file|
          time_now = DateTime.now
          id = time_now.strftime('%Q').to_i + Random.rand(999999)
          file_name = "#{id}_#{file['name']}"
          display_name = "#{file['name']} (#{time_now.strftime('%d.%m.%Y %H:%M:%S')})"

          obj = bucket.object(file_name)
          obj.put(body: Base64.decode64(file['content']))

          result.push({url:         obj.public_url,
                       name:        display_name,
                       origin_name: file['name'],
                       real_name:   file_name,
                       upload_time: time_now.iso8601,
                       end_point:   HBW::Widget.config[:minio][:endpoint],
                       bucket:      HBW::Widget.config[:minio][:bucket]})
        end
      end

      result
    end
  end
end
