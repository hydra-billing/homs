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

    describe 'with basic auth credentials' do
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

    describe 'with JWT header' do
      let(:keycloak_client) { double(:keycloak_client) }
      let(:valid_jwt) { 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0MEdqNUcya09FbHk1aXdhOTF1SlhscG5pZkhYbDVzWl9fZm9RQXA2R2RRIn0.eyJleHAiOjE2NzU3ODA5NjcsImlhdCI6MTY3NTc4MDY2NywianRpIjoiNGRkMzJjZWYtOTRkNS00ZjAxLWI4OTQtYTI4ZjEyYzNhNjdjIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDA4L2F1dGgvcmVhbG1zL2h5ZHJhIiwiYXVkIjpbImhvcGVyIiwiYWNjb3VudCJdLCJzdWIiOiIzMmI2NzQyNS0wZWI5LTQ4MTUtYjUzNS0yYmUwNmI4YzUyZTAiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJob21zIiwic2Vzc2lvbl9zdGF0ZSI6ImQ3ZGE4NmQ5LTUxZDUtNDljMi1hMWY1LWMxNjQxMWM5NGI1ZiIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJkZWZhdWx0LXJvbGVzLWh5ZHJhIiwidW1hX2F1dGhvcml6YXRpb24iXX0sInJlc291cmNlX2FjY2VzcyI6eyJob3BlciI6eyJyb2xlcyI6WyLQmNC90LbQtdC90LXRgCDQv9C-INGN0LrRgdC_0LvRg9Cw0YLQsNGG0LjQuCDQkNCh0KAiLCLQkdGD0YXQs9Cw0LvRgtC10YAiXX0sImhvbXMiOnsicm9sZXMiOlsidXNlciJdfSwiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJvcGVuaWQgZW1haWwgaG9tcyBwcm9maWxlIiwic2lkIjoiZDdkYTg2ZDktNTFkNS00OWMyLWExZjUtYzE2NDExYzk0YjVmIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJuYW1lIjoiVVNFUk5BTUUgVVNFUlNVUk5BTUUiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJzc29fdXNlciIsImdpdmVuX25hbWUiOiJVU0VSTkFNRSIsImZhbWlseV9uYW1lIjoiVVNFUlNVUk5BTUUiLCJlbWFpbCI6InNzb191c2VyQHRlc3QuY29tIn0.g0zWcqcou9o7Hy0sLB77QANlm1VhF2zYIJimK8S8b_O6IUcgsKp9eDLiteGIyeONtoWozZoA9XYXffRVCrAWsTJlzjQ_88jdanvrxUVhfLBObGScI1HcqSk-k9qsOqdxcUifaz4jyrvkGyObnfJ6myhqS3JqSsTiTU6b8dHon4gVLaV7HdXITq3TJnZwng2lWw-WwaWFMVmJP_Hr8TbucB2tzZiqUTaGnVnaU1C9G1YnZrXOkS9BJHrOG3C7BIYYsfnG7vJsQf4aSMMzn2FeYr9kx32S1X218DpEIBooAA3rVayU5uSmyMM1Bx5DWyeBxuKL6MD3tWVCAKaOUaHlxA' }
      let(:jwt_wo_required_fields) { 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0MEdqNUcya09FbHk1aXdhOTF1SlhscG5pZkhYbDVzWl9fZm9RQXA2R2RRIn0.eyJleHAiOjE2NzU2OTUzNzIsImlhdCI6MTY3NTY5NTA3MiwianRpIjoiODY3ZTUzOGQtOWQ5ZS00ODEzLTlkMWQtM2M0YmJjYzY1NjQwIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDA4L2F1dGgvcmVhbG1zL2h5ZHJhIiwiYXVkIjpbImhvcGVyIiwiYWNjb3VudCJdLCJzdWIiOiIzMmI2NzQyNS0wZWI5LTQ4MTUtYjUzNS0yYmUwNmI4YzUyZTAiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJob21zIiwic2Vzc2lvbl9zdGF0ZSI6IjMyNjVlNTkzLTNlYTktNGVkZS1hZGEwLWVkYzVkZDQwZDdmZiIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJkZWZhdWx0LXJvbGVzLWh5ZHJhIiwidW1hX2F1dGhvcml6YXRpb24iXX0sInJlc291cmNlX2FjY2VzcyI6eyJob3BlciI6eyJyb2xlcyI6WyLQmNC90LbQtdC90LXRgCDQv9C-INGN0LrRgdC_0LvRg9Cw0YLQsNGG0LjQuCDQkNCh0KAiLCLQkdGD0YXQs9Cw0LvRgtC10YAiXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoib3BlbmlkIGVtYWlsIGhvbXMgcHJvZmlsZSIsInNpZCI6IjMyNjVlNTkzLTNlYTktNGVkZS1hZGEwLWVkYzVkZDQwZDdmZiIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwibmFtZSI6IlVTRVJOQU1FIFVTRVJTVVJOQU1FIiwicHJlZmVycmVkX3VzZXJuYW1lIjoic3NvX3VzZXIiLCJnaXZlbl9uYW1lIjoiVVNFUk5BTUUiLCJmYW1pbHlfbmFtZSI6IlVTRVJTVVJOQU1FIiwiZW1haWwiOiJzc29fdXNlckB0ZXN0LmNvbSJ9.jxFAJ7p4fxiGJvDKv_a1ZPahuk2AQC0LeuYMYIqCTdL94YYI9Me_R531jB9eBMqFIygq1di5rlBk1XO035agyAQnvyzIdf_yTEuAq6iEr9FxDRzD4usEEXsD0MQmM8ghvTkNZpI-FrHTvwSa3rHgrLlSJ_OmNzwE9cncZLzSb23GOhJBev_IAaedY2SEmvj88wg4qIXlgx6Aqj8gnZaNfw14OKzqZPFZcVEfOSUgp_IA2qUtmyZK0vcvvhw6BlTPLXUk5XabmOaWn7UvLUt3TjxLfJbmJGhoXkOW8bkCOrgYuFWtsZt-ZJjBVxUSv6g6PBpKdj_y9mJGVarfrIovdA' }
      let(:invalid_jwt) { 'invalid_jwt' }

      before do
        HOMS::Container.stub(:keycloak_client, keycloak_client)

        allow(Rails.application.config.app).to receive(:fetch).and_call_original
        allow(Rails.application.config.app).to receive(:fetch).with(:sso, {}).and_return(
          {
            **Rails.application.config.app.sso,
            enabled: true
          }
        )

        allow(keycloak_client).to receive(:introspect_token) do |token|
          case token
          when valid_jwt, jwt_wo_required_fields
            Success(token)
          when invalid_jwt
            Failure(status: 400, code: :token_not_active)
          end
        end
      end

      it 'returns :success for correct JWT' do
        add_jwt_auth_header(valid_jwt)

        get :new
        expect(response).to have_http_status(:success)
      end

      it 'returns :unauthorized for JWT containing not all the required fields' do
        add_jwt_auth_header(jwt_wo_required_fields)

        get :new
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns :unauthorized for invalid JWT' do
        add_jwt_auth_header(invalid_jwt)

        get :new
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
