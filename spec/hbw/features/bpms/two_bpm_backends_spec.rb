feature 'Using two BPM data sources', js: true do
  let(:first_task_due_date)  { DateTime.parse('2016-07-30T12:07:59').in_time_zone }
  let(:second_task_due_date) { DateTime.parse('2017-07-30T12:07:59').in_time_zone }

  def set_mocks
    HBW::Container.stub(
      :api,
      [
        HBW::Camunda::YMLAPI.for_prosess_keys('spec/hbw/features/bpms/first_bpm_backend_mock.yml', ['support_request']),
        HBW::Camunda::YMLAPI.for_prosess_keys('spec/hbw/features/bpms/second_bpm_backend_mock.yml', %w[new_customer some_other_process_key])
      ]
    )
  end

  before(:each) do
    set_mocks

    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    support_request_order_type = FactoryBot.create(:order_type, :support_request)
    new_customer_order_type = FactoryBot.create(:order_type, :new_customer)

    FactoryBot.create(:order, order_type: support_request_order_type)
    FactoryBot.create(:order, order_type: new_customer_order_type)
  end

  describe 'task form rendered' do
    scenario 'from the first data source' do
      click_on 'Orders'
      expect(page).to have_content 'Orders list'
      expect_widget_presence

      click_and_wait 'ORD-1'

      expect(page).to have_content 'ORD-1'
      expect(page).to have_content 'Static field from the first data source'
      expect_widget_presence
    end

    scenario 'from the secound data source' do
      click_on 'Orders'
      expect(page).to have_content 'Orders list'
      expect_widget_presence

      click_and_wait 'ORD-2'

      expect(page).to have_content 'ORD-2'
      expect(page).to have_content 'Static field from the second data source'
      expect_widget_presence
    end
  end

  scenario 'tasks from both sources are rendered in popup' do
    expect(tasks_count).to eq '2/0'

    click_on_tasks_counter
    wait_for_ajax

    expect(page).to have_content 'My tasks (2)'
    expect(page).to have_content 'Unclaimed tasks (0)'

    expect(popup_tasks_list_content).to eq(
      [
        "Task from the second source\n30 Jun 2016",
        "Task from the first source\n01 Jun 2016"
      ]
    )
  end
end
