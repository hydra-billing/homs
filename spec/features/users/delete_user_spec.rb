feature 'Delete user', :devise, js: true do
  before(:each) do
    admin = FactoryBot.create(:user, :admin)
    @user = FactoryBot.create(:user, :john)
    signin(admin.email, admin.password)
  end

  scenario 'we can delete user' do
    visit '/users'
    click_link("#{@user.name} #{@user.last_name}")
    expect(page).to have_content I18n.t('users.edit.title')

    click_link(I18n.t('users.show.delete_user'))
    expect(current_path.should).to   eq('/users')
    expect(page).to have_no_content  @user.email
  end
end
