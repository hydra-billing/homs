feature 'Check available tasks counter', js: true do
  before(:each) do
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'
  end

  describe 'rendered' do
    it 'with count of assigned/unassigned tasks' do
      expect_widget_presence

      expect(tasks_count).to eq '5/10'
    end
  end
end
