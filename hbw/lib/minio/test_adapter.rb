require 'aws-sdk-s3'

module Minio
  class TestAdapter
    extend Imprint::Mixin

    def save_files(files)
      s3 = Aws::S3::Resource.new(client: Minio::Container[:s3])
      bucket = s3.bucket(HBW::Widget.config[:minio][:bucket])

      files.map do |file|
        id = DateTime.now.strftime('%Q').to_i + Random.rand(999999)
        file_name = "#{id}_#{file['name']}"

        obj = bucket.object(file_name)
        obj.put(body: Base64.decode64(file['content']))

        {
          origin_name: file['name'],
          field_name:  file['fieldName'],
          end_point:   HBW::Widget.config[:minio][:endpoint],
          bucket:      'bucket-name'
        }
      end
    end
  end
end
