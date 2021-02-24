feature 'Check table with tasks', js: true do
  let(:first_task_due_date)  { DateTime.parse('2016-07-30T12:07:59').in_time_zone }
  let(:second_task_due_date) { DateTime.parse('2017-07-30T12:07:59').in_time_zone }

  before(:each) do
    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-23')

    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_on 'Tasks'
    expect_widget_presence
    expect(page).to have_content 'Open tasks'
    expect(page).to have_content 'My tasks (34)'
    expect(page).to have_content 'Unclaimed tasks (3)'
  end

  describe 'task list rendered' do
    it 'for tasks assigned to current user' do
      expect(tasks_table_header).to eq ['Priority', 'Title', 'Task type', 'Task description', 'Created/Due']

      expect(tasks_table_content).to eq(
        [
          ['Medium', 'Assigned task', ' Test name', '—', "expired (#{years_since(first_task_due_date)}y past due date)"],
          ['High', 'Other assigned task', ' Test name', 'Some test description', "expired (#{years_since(second_task_due_date)}y past due date)"],
          ['High', "Enter customer's address", ' New Customer', '—', '30 Jun 2016'],
          *Array.new(31) { ['High', 'Check test form', ' Test name', '—', '30 Jun 2016'] }
        ]
      )
    end

    it 'for unclaimed tasks' do
      click_on_tab 'Unclaimed tasks (3)'

      expect(tasks_table_header).to eq ['Priority', 'Title', 'Task type', 'Task description', 'Created/Due', '']

      expect(tasks_table_content).to eq(
        [
          ['Medium', 'Unassigned task', ' Test name', '—', "expired (#{years_since(first_task_due_date)}y past due date)", 'Claim'],
          ['High', 'Other unassigned task', ' Test name', 'Some test description', "expired (#{years_since(second_task_due_date)}y past due date)", 'Claim'],
          ['High', 'Check test form', ' Test name', '—', '30 Jun 2016', 'Claim']
        ]
      )
    end
  end

  describe 'task overview rendered' do
    before(:each) do
      expect(page).not_to have_content 'Task overview'
    end

    it 'for assigned task' do
      expect(tasks_table_content.length).to eq(34)

      click_on_task_table_row(1)

      expect(page).to have_content 'Task overview'
      expect(page).to have_content 'Go to task'
      expect(page).not_to have_content 'Claim task'
      expect(page).not_to have_content 'Claim and go to task'

      task_overview = find_by_dt('task-overview')

      expect(find_by_dt('title-link', task_overview).text).to         eq 'Test name — Assigned task'
      expect(find_by_dt('due-date-value', task_overview).text).to     eq '07/30/2016 09:07 am'
      expect(find_by_dt('created-date-value', task_overview).text).to eq '06/30/2016 09:07 am'
      expect(find_by_dt('priority-value', task_overview).text).to     eq 'Medium'
      expect(miss_by_dt('description-value', task_overview)).to       eq true

      click_on_task_table_row(2)

      expect(page).to have_content 'Task overview'
      task_overview = find_by_dt('task-overview')

      expect(find_by_dt('title-link', task_overview).text).to         eq 'Test name — Other assigned task'
      expect(find_by_dt('due-date-value', task_overview).text).to     eq '07/30/2017 09:07 am'
      expect(find_by_dt('created-date-value', task_overview).text).to eq '06/30/2016 09:07 am'
      expect(find_by_dt('priority-value', task_overview).text).to     eq 'High'
      expect(find_by_dt('description-value', task_overview).text).to  eq 'Some test description'

      click_on 'Go to task'

      expect(page).to have_content 'ORD-23'
      expect(page).to have_content 'Check test form'
    end

    it 'for unassigned task' do
      click_on_tab 'Unclaimed tasks (3)'

      expect(tasks_table_content.length).to eq(3)

      click_on_task_table_row(2)

      expect(page).to have_content 'Task overview'
      expect(page).to have_content 'Claim task'
      expect(page).to have_content 'Claim and go to task'
      expect(page).not_to have_content 'Go to task'

      task_overview = find_by_dt('task-overview')

      expect(find_by_dt('title-link', task_overview).text).to         eq 'Test name — Other unassigned task'
      expect(find_by_dt('due-date-value', task_overview).text).to     eq '07/30/2017 09:07 am'
      expect(find_by_dt('created-date-value', task_overview).text).to eq '06/30/2016 09:07 am'
      expect(find_by_dt('priority-value', task_overview).text).to     eq 'High'
      expect(find_by_dt('description-value', task_overview).text).to  eq 'Some test description'

      click_on 'Claim and go to task'

      expect(page).to have_content 'ORD-23'
      expect(page).to have_content 'Check test form'
    end
  end

  describe 'table row disabled' do
    it 'for claimed task' do
      click_on_tab 'Unclaimed tasks (3)'

      claim_task(1)

      check_row_is_claiming(1)
      wait_for_ajax
      check_row_is_not_claiming(1)
    end
  end
end
