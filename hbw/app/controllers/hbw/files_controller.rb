require 'minio'

module HBW
  class FilesController < BaseController
    include Minio
    extend Minio::Mixin

    inject['minio_adapter']

    def upload
      files = JSON.parse(params['files'])
      saved_files = minio_adapter.save_file(files)

      render json: saved_files.to_json, status: :ok
    end
  end
end
