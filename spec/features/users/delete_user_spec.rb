feature 'Delete user', :devise, js: true do
  before(:each) do
    admin = FactoryBot.create(:user, :admin)
    @user = FactoryBot.create(:user, :john)
    signin(admin.email, admin.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'
  end

  scenario 'we can delete user' do
    visit '/users'
    click_link("#{@user.name} #{@user.last_name}")
    expect(page).to have_content I18n.t('users.edit.title')

    click_link(I18n.t('users.show.delete_user'))
    expect(page).to have_current_path('/users')
    expect(page).to have_no_content @user.email
  end
end
