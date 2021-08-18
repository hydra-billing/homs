feature 'Sign in', :devise, js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/features/users/users_mock.yml')
  end

  let(:user) { FactoryBot.create(:user) }

  scenario 'user cannot sign in if not registered' do
    signin('test@example.com', 'please123')
    expect(page).to have_content I18n.t 'layouts.navigation.sign_in'
  end

  scenario 'user can sign in with valid credentials' do
    signin(user.email, user.password)
    expect(page).not_to have_content I18n.t 'layouts.navigation.sign_in'
    expect(page).to have_content I18n.t 'orders.index.title'
  end

  scenario 'user cannot sign in with wrong email' do
    signin('invalid@email.com', user.password)
    expect(page).to have_content I18n.t 'layouts.navigation.sign_in'
    expect(page).to have_content I18n.t('devise.failure.invalid', authentication_keys: I18n.t('activerecord.attributes.user.email'))
  end

  scenario 'user cannot sign in with wrong password' do
    signin(user.email, 'invalidpass')
    expect(page).to have_content I18n.t 'layouts.navigation.sign_in'
    expect(page).to have_content I18n.t('devise.failure.invalid', authentication_keys: I18n.t('activerecord.attributes.user.email'))
  end
end
