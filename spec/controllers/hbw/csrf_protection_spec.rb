require 'base64'

describe 'HBW CSRF protection', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user)   { FactoryBot.create(:user, api_token: 'api-token-123') }
  let(:widget) { instance_double(HBW::Widget) }

  let(:button_params) do
    {bp_code:      'support_request',
     entity_code:  '100500',
     entity_type:  'order',
     entity_class: 'odoo'}
  end

  around(:each) do |example|
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = false
  end

  before(:each) do
    allow(widget).to receive(:start_bp)
    allow(widget).to receive(:bp_buttons).and_return({buttons: [], bp_running: false})
    allow_any_instance_of(HBW::ButtonsController).to receive(:widget).and_return(widget)
  end

  context 'with a session-authenticated browser client' do
    before(:each) { sign_in user }

    it 'rejects a mutating request without a CSRF token' do
      post '/widget/buttons', params: button_params

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'accepts a mutating request with the CSRF token from the page meta tag' do
      get root_path
      token = Nokogiri::HTML(response.body).at('meta[name="csrf-token"]')['content']

      post '/widget/buttons', params: button_params, headers: {'X-CSRF-Token' => token}

      expect(response).to have_http_status(:success)
    end
  end

  context 'with an Authorization-header client' do
    let(:auth_headers) do
      {'Authorization' => "Basic #{Base64.strict_encode64("#{user.email}:#{user.api_token}")}"}
    end

    it 'accepts starting a business process without a CSRF token' do
      post '/widget/buttons', params: button_params, headers: auth_headers

      expect(response).to have_http_status(:success)
    end

    it 'accepts a file upload without a CSRF token' do
      minio_adapter = double(save_files: [])
      allow_any_instance_of(HBW::FilesController).to receive(:minio_adapter).and_return(minio_adapter)

      post '/widget/files/upload', params: {files: [].to_json}, headers: auth_headers

      expect(response).to have_http_status(:success)
    end
  end
end
