include Warden::Test::Helpers
Warden.test_mode!

# Feature: User index page
#   As a user
#   I want to see a list of users
#   So I can see who has registered
feature 'User index page', :devise, js: true do
  after(:each) do
    Warden.test_reset!
  end

  before(:each) do
    set_camunda_api_mock_file('spec/features/users/users_mock.yml')
  end

  # Scenario: User listed on index page
  #   Given I am signed in
  #   When I visit the user index page
  #   Then I see my own email address
  scenario 'user sees own email address' do
    user = FactoryBot.create(:user, :admin)
    login_as(user, scope: :user)
    visit users_path
    expect(page).to have_content user.email
  end
end
