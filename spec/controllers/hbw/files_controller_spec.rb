require 'base64'
require 'aws-sdk-s3'
require 'dry/container/stub'

RSpec.describe HBW::FilesController, type: :controller do
  routes { HBW::Engine.routes }

  let(:user)      { FactoryBot.create(:user) }
  let(:file_path) { Rails.root.join('fixtures/attached_files/file.txt') }

  before(:each) { sign_in(user) }

  describe 'Files' do
    it 'upload' do
      file = {
        name:      'file.txt',
        fieldName: 'variableAssociatedWithFile',
        content:   Base64.encode64(File.read(file_path))
      }

      post 'upload', params: {files: [file].to_json}

      expect(JSON.parse(response.body).first.symbolize_keys).to include(
        origin_name: file[:name],
        field_name:  file[:fieldName],
        end_point:   HBW::Widget.config[:minio][:endpoint],
        bucket:      'bucket-name'
      )
    end
  end
end
