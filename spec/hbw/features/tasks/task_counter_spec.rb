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
      expect(tasks_count).to eq '5/10'
    end
  end

  describe 'when expanded to pop up' do
    before(:each) do
      click_on_tasks_counter
      wait_for_ajax
    end

    it 'should contain two tabs with list' do
      expect(page).to have_content 'My tasks (5)'
      expect(page).to have_content 'Unassigned tasks (10)'

      expect(popup_tasks_list_content).to eq(
        [
          "Assigned task for popup\nexpired",
          "Other assigned task for popup\nSome test description\n30 Jun 2016"
        ]
      )

      click_on_tab 'Unassigned tasks (10)'

      expect(popup_tasks_list_content).to eq(
        [
          "Unassigned task for popup\nexpired",
          "Other unassigned task for popup\nSome test description\n30 Jun 2016"
        ]
      )

      click_on_tasks_counter

      expect(page).not_to have_content 'My tasks (5)'
      expect(page).not_to have_content 'Unassigned tasks (10)'

      expect_widget_presence
    end

    it 'should allow to navigate to full task list' do
      expect(page).to have_content 'View all'

      click_on 'View all'

      expect(page).to have_content 'Open tasks'
    end

    it 'should allow to navigate to task' do
      expect(page).to have_content 'Assigned task for popup'

      click_on_task_list_row(2)

      expect(page).to have_content 'ORD-23'
      expect(page).to have_content 'Check test form'
    end
  end
end
