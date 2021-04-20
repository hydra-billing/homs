require 'minio'

module HBW
  class FilesController < BaseController
    include Minio
    extend Minio::Mixin

    inject['minio_adapter']

    def upload
      if request.path.end_with?('/file_upload')
        warn '[DEPRECATION] Endpoint `/widget/file_upload` is deprecated.  Please use `/widget/files/upload` instead.'
      end

      files = JSON.parse(params['files'])
      saved_files = minio_adapter.save_file(files)

      render json: saved_files.to_json, status: :ok
    end
  end
end
