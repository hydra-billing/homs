require 'acceptance_helper'

describe API::V1::UsersController, type: :request do
  resource I18n.t('doc.users.resource') do
    include HttpAuthHelper

    before(:each) do
      disable_http_basic_authentication(API::V1::UsersController)
    end

    header 'Accept',       'application/json'
    header 'Content-Type', 'application/json'

    let!(:david) { FactoryBot.create(:user, :david) }
    let!(:user) do
      User.create!(
          email: 'user@example.com',
          password: 'changeme',
          name: 'John',
          last_name: 'Doe',
          role: :admin,
          company: 'Example Corporation',
          department: 'Administrators',
          api_token: 'RENEWMEPLEASE',
          blocked: false,
          external: false)
    end

    get '/api/users?page_size=:page_size&page=:page' do
      parameter :page_size,
                 I18n.t('doc.common.parameters.page_size'),
                {I18n.t('doc.common.parameters.default') => 25}
      parameter :page,
                I18n.t('doc.common.parameters.page'),
                {I18n.t('doc.common.parameters.default') => 1}

      example_request I18n.t('doc.common.cases.list'),
                      page_size: 1, page: 2 do
        expect(status).to eq(200)
        expect(JSON response_body).to eq(
                                          'users' => [
                                              {
                                                  'email'       => 'demo@example.com',
                                                  'name'        => 'David',
                                                  'last_name'   => 'Jones',
                                                  'middle_name' => nil,
                                                  'company'     => 'Example Corporation',
                                                  'department'  => 'Demonstrations',
                                                  'role'        => 'user',
                                                  'blocked'     => false,
                                                  'external'    => false
                                              }
                                          ]
                                      )
      end
    end

    get '/api/users/:email' do
      parameter :email, I18n.t('doc.users.parameters.email'), required: true

      let(:email) { 'demo@example.com' }

      example_request I18n.t('doc.common.cases.show') do
        expect(status).to eq(200)
        expect(JSON response_body).to eq(
                                          'user' => {
                                              'email'       => 'demo@example.com',
                                              'name'        => 'David',
                                              'last_name'   => 'Jones',
                                              'middle_name' => nil,
                                              'company'     => 'Example Corporation',
                                              'department'  => 'Demonstrations',
                                              'role'        => 'user',
                                              'blocked'     => false,
                                              'external'    => false
                                          }
                                      )
      end
    end

    put '/api/users/:email' do
      parameter :email,       I18n.t('doc.users.parameters.email'),       required: true
      parameter :name,        I18n.t('doc.users.parameters.first_name'),  scope: :user
      parameter :middle_name, I18n.t('doc.users.parameters.middle_name'), scope: :user
      parameter :last_name,   I18n.t('doc.users.parameters.last_name'),   scope: :user
      parameter :role,        I18n.t('doc.users.parameters.user_role'),   scope: :user
      parameter :company,     I18n.t('doc.users.parameters.company'),     scope: :user
      parameter :department,  I18n.t('doc.users.parameters.department'),  scope: :user
      parameter :blocked,     I18n.t('doc.users.parameters.blocked'),     scope: :user
      parameter :external,    I18n.t('doc.users.parameters.external'),    scope: :user

      let(:middle_name) { 'Jay' }
      let(:email)       { 'demo@example.com' }
      let(:blocked)     { true }
      let(:external)    { true }
      let(:raw_post)    { params.to_json }

      example_request I18n.t('doc.common.cases.update') do
        updated_user = User.find_by_email(email)
        expect(status).to eq(200)
        expect(JSON response_body).to eq(
                                          'user' => {
                                              'email'       => 'demo@example.com',
                                              'name'        => 'David',
                                              'last_name'   => 'Jones',
                                              'middle_name' => 'Jay',
                                              'company'     => 'Example Corporation',
                                              'department'  => 'Demonstrations',
                                              'role'        => 'user',
                                              'blocked'     => true,
                                              'external'    => true
                                          }
                                      )
        expect(updated_user.middle_name).to eq(middle_name)
      end
    end

    post '/api/users' do
      parameter :email,       I18n.t('doc.users.parameters.email'),       required: true, scope: :user
      parameter :name,        I18n.t('doc.users.parameters.first_name'),  required: true, scope: :user
      parameter :middle_name, I18n.t('doc.users.parameters.middle_name'), scope: :user
      parameter :last_name,   I18n.t('doc.users.parameters.last_name'),   required: true, scope: :user
      parameter :role,        I18n.t('doc.users.parameters.user_role'),  {:scope                                         => :user,
                                                                          I18n.t('doc.common.parameters.allowed_values') => User.roles_list.join(', '),
                                                                          I18n.t('doc.common.parameters.default')        => 'user'}
      parameter :company,     I18n.t('doc.users.parameters.company'),     required: true, scope: :user
      parameter :department,  I18n.t('doc.users.parameters.department'),  required: true, scope: :user
      parameter :password,    I18n.t('doc.users.parameters.password'),    required: true, scope: :user

      let(:raw_post)    { params.to_json }
      let(:email)       { 's.collins@example.com' }
      let(:name)        { 'Stan' }
      let(:middle_name) { 'Kay' }
      let(:last_name)   { 'Collins' }
      let(:role)        { 'admin' }
      let(:company)     { 'LLC Tools' }
      let(:department)  { 'Administrators' }
      let(:password)    { 'changeme' }

      example_request I18n.t('doc.common.cases.create') do
        expect(status).to eq(201)
        expect(JSON response_body).to eq(
                                          'user' => {
                                              'email'       => 's.collins@example.com',
                                              'name'        => 'Stan',
                                              'last_name'   => 'Collins',
                                              'middle_name' => 'Kay',
                                              'company'     => 'LLC Tools',
                                              'department'  => 'Administrators',
                                              'role'        => 'admin',
                                              'blocked'     => false,
                                              'external'    => false
                                          }
                                      )
      end
    end

    delete '/api/users/:email' do
      parameter :email, I18n.t('doc.users.parameters.email'), required: true

      let(:email) { 'demo@example.com' }

      example_request I18n.t('doc.common.cases.delete') do
        expect(status).to eq(204)
        expect(User.find_by_email(email)).to be_nil
      end
    end
  end
end
