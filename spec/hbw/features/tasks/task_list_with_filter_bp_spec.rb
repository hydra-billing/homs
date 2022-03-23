feature 'Check table with tasks (candidate_starters is enabled)', js: true do
  let(:first_task_due_date)  { DateTime.parse('2016-07-30T12:07:59').in_time_zone }
  let(:second_task_due_date) { DateTime.parse('2017-07-30T12:07:59').in_time_zone }

  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/tasks/task_list_with_filter_bp_mock.yml')

    set_candidate_starters(true)

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type) # ORD-1

    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_on 'Tasks'
    expect_widget_presence
    expect(page).to have_content 'Open tasks'
    expect(page).to have_content 'My tasks (2)'
    expect(page).to have_content 'Unclaimed tasks (3)'
  end

  after(:each) do
    set_candidate_starters(false)
  end

  describe 'task list rendered' do
    it 'for tasks assigned to current user' do
      expect(tasks_table_header).to eq ['Priority', 'Title', 'Task type', 'Task description', 'Created/Due']

      expect(tasks_table_content).to eq(
        [
          ['Medium', 'Assigned task', ' Test name', '—', "expired (#{years_since(first_task_due_date)}y past due date)"],
          ['High', 'Other assigned task', ' Test name', 'Some test description', "expired (#{years_since(second_task_due_date)}y past due date)"]
        ]
      )
    end
  end
end
