feature 'Check table with tasks', js: true do
  before(:each) do
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_on 'Tasks'
    expect_widget_presence
    expect(page).to have_content 'Open tasks'
    expect(page).to have_content 'My tasks (5)'
    expect(page).to have_content 'Unassigned tasks (10)'
  end

  describe 'task list rendered' do
    it 'for tasks assigned to current user' do
      expect(tasks_table_header).to eq ['Priority', 'Title', 'Task type', 'Task description', 'Created']

      expect(tasks_table_content).to eq(
        [
          ['Medium', 'Check test form', ' Test name', 'No description', 'expired'],
          ['High', 'Check test form', ' Test name', 'Some test description', '30 Jun 2016']
        ]
      )
    end

    it 'for unassigned tasks' do
      click_on_tab 'Unassigned tasks (10)'

      expect(tasks_table_header).to eq ['Priority', 'Title', 'Task type', 'Task description', 'Created', '']

      expect(tasks_table_content).to eq(
        [
          ['Medium', 'Check test form', ' Test name', 'No description', 'expired', 'Claim'],
          ['High', 'Check test form', ' Test name', 'Some test description', '30 Jun 2016', 'Claim']
        ]
      )
    end
  end

  describe 'table row disabled' do
    it 'for claimed task' do
      click_on_tab 'Unassigned tasks (10)'

      claim_task(1)

      check_row_is_claiming(1)
      wait_for_ajax
      check_row_is_not_claiming(1)
    end
  end
end
