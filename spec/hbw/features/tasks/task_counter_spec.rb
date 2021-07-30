feature 'Check available tasks counter', js: true do
  before(:each) do
    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-23')

    user = FactoryBot.create(:user)
    signin(user.email, user.password)

    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'
    expect_widget_presence
  end

  describe 'when rendered' do
    it 'should contain assigned/unassigned tasks count' do
      expect(tasks_count).to eq '40/3'
    end
  end

  describe 'when expanded to pop up' do
    let(:first_task_due_date)  { DateTime.parse('2016-07-30T12:07:59').in_time_zone }
    let(:second_task_due_date) { DateTime.parse('2017-07-30T12:07:59').in_time_zone }

    before(:each) do
      click_on_tasks_counter
      wait_for_ajax
    end

    it 'should contain two tabs with list' do
      expect(page).to have_content 'My tasks (40)'
      expect(page).to have_content 'Unclaimed tasks (3)'

      expect(popup_tasks_list_content).to eq(
        [
          "Assigned task\nexpired (#{years_since(first_task_due_date)}y past due date)",
          "Other assigned task\nSome test description\nexpired (#{years_since(second_task_due_date)}y past due date)",
          "Check test form\n30 Jun 2016",
          "Check test form\n30 Jun 2016",
          "Check test form\n30 Jun 2016",
          "Check test form\n30 Jun 2016",
          "Check test form\n30 Jun 2016",
          "Check test form\n30 Jun 2016",
          "Check test form\n30 Jun 2016",
          "Check test form\n30 Jun 2016"
        ]
      )

      click_on_tab 'Unclaimed tasks (3)'

      expect(popup_tasks_list_content).to eq(
        [
          "Unassigned task\nexpired (#{years_since(first_task_due_date)}y past due date)",
          "Other unassigned task\nSome test description\nexpired (#{years_since(second_task_due_date)}y past due date)",
          "Check test form\n30 Jun 2016"
        ]
      )

      click_on_tasks_counter

      expect(page).not_to have_content 'My tasks (40)'
      expect(page).not_to have_content 'Unclaimed tasks (3)'

      expect_widget_presence
    end

    it 'should allow to navigate to full task list' do
      expect(page).to have_content 'View all'

      click_on 'View all'

      expect(page).to have_content 'Open tasks'
    end

    it 'should allow to navigate to task' do
      expect(page).to have_content 'Assigned task'

      click_on_task_list_row(2)

      expect(page).to have_content 'ORD-23'
      expect(page).to have_content 'Check test form'
    end
  end
end
