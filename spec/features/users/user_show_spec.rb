include Warden::Test::Helpers

Warden.test_mode!

feature 'User profile page', :devise, js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/features/users/users_mock.yml')
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'user sees own profile' do
    user = FactoryBot.create(:user)
    login_as(user, scope: :user)
    visit user_path(user)
    expect(page).to have_content 'User'
    expect(page).to have_content user.email
  end

  scenario "user cannot see another user's profile" do
    me = FactoryBot.create(:user)
    other = FactoryBot.create(:user, email: 'other@example.com')
    login_as(me, scope: :user)

    visit user_path(other)

    expect(page).to have_content 'Orders list'
  end
end
