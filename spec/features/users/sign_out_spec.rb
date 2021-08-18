feature 'Sign out', :devise, js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/features/users/users_mock.yml')
  end

  scenario 'user signs out successfully' do
    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).to have_content I18n.t 'orders.index.title'
    logout
    expect(page).to have_content I18n.t 'devise.sessions.new.title'
  end
end
