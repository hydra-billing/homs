describe HttpAuthentication, type: :controller do
  include HttpAuthHelper

  controller(ApplicationController) do
    include HttpAuthentication

    before_action :perform_http_authentication, only: [:new]

    def index
      render plain: 'index'
    end

    def new
      render plain: 'new'
    end
  end

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
      get 'new'   => 'anonymous#new'
    end
  end

  describe '#perform_http_authentication' do
    describe 'with no credentials' do
      it 'returns :success for unprotected action' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'returns :unauthorized for protected action' do
        get :new
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe 'with credentials' do
      let(:user) { FactoryBot.create(:user, :john, api_token: 'please123') }
      let(:email) { user.email }
      let(:password) { user.api_token }
      let(:wrong_password) { "#{password}!" }
      let(:wrong_email) { "s.#{email}" }

      it 'returns :success for right credentials' do
        add_http_auth_header(email, password)

        get :new
        expect(response).to have_http_status(:success)
      end

      it 'returns :unauthorized for wrong password' do
        add_http_auth_header(email, wrong_password)

        get :new
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns :unauthorized for nil password' do
        add_http_auth_header(email, nil)

        get :new
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns :unauthorized for wrong email' do
        add_http_auth_header(wrong_email, password)

        get :new
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns :unauthorized for nil email' do
        add_http_auth_header(nil, password)

        get :new
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
