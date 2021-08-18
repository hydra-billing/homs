feature 'Create new order', js: true do
  let(:contract_number)            { '123456' }
  let(:invalid_contract_number)    { 'qwerty' }
  let(:problem_descr)              { 'Problem description' }
  let(:employee)                   { 'Employee' }
  let(:approver)                   { 'Approver' }
  let(:order_code)                 { 'ORD-1' }
  let(:current_date)               { Date.today.strftime('%m/%d/%Y') }
  let(:support_request_type_name)  { 'Support request' }
  let(:vacation_request_type_name) { 'Vacation request' }

  before(:each) do
    set_camunda_api_mock_file('spec/features/orders/orders_mock.yml')

    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    FactoryBot.create(:order_type, :support_request, name: support_request_type_name)
    FactoryBot.create(:order_type, :vacation_request, name: vacation_request_type_name)
  end

  describe 'success' do
    before(:each) do
      click_on 'Orders'
      expect(page).to have_content 'Orders list'
      expect_widget_presence

      click_on 'Add'
      expect(page).to have_content 'Add order'
      expect_widget_presence
    end

    scenario 'support request' do
      click_on_calendar('order_data_creationDate')
      click_checkbox_div('order_data_callBack')
      fill_in('order[data][problemDescription]', with: problem_descr)
      fill_in('order[data][contractNumber]',     with: contract_number)
      click_and_wait('Add')

      expect(page).to                                 have_content order_code
      expect(find_by_title('Creation date')).to       have_content current_date
      expect(find_by_title('Contract number')).to     have_content contract_number
      expect(find_by_title('Problem description')).to have_content problem_descr
      expect(find_by_title('Callback').first('.fa-check')).not_to  eq(nil)
      expect(Order.find_by_code(order_code).present?).to           be_truthy
      expect_widget_presence
    end

    scenario 'vacation request' do
      expect(select_options('order_type_id')).to eq([support_request_type_name,
                                                     vacation_request_type_name])

      expect(select2_text('order_type_id')).to eq(support_request_type_name)
      expect(page).to have_content 'Problem description'
      expect(page).to have_content 'Callback'
      expect(page).to have_content 'Contract number'

      change_select2_value('order_type_id', 'Vacation request')
      wait_for_ajax

      expect(select2_text('order_type_id')).to eq(vacation_request_type_name)

      expect(page).not_to have_content 'Problem description'
      expect(page).not_to have_content 'Callback'
      expect(page).not_to have_content 'Contract number'

      expect(page).to have_content 'Leave date'
      expect(page).to have_content 'Vacation end date'
      expect(page).to have_content 'Employee'
      expect(page).to have_content 'Approver'

      click_on_calendar('order_data_vacationLeaveDate')
      click_on_calendar('order_data_vacationBackDate')
      fill_in('order[data][employee]', with: employee)
      fill_in('order[data][approver]', with: approver)
      click_and_wait('Add')

      expect(page).to                               have_content order_code
      expect(find_by_title('Leave date')).to        have_content current_date
      expect(find_by_title('Vacation end date')).to have_content current_date
      expect(find_by_title('Employee')).to          have_content employee
      expect(find_by_title('Approver')).to          have_content approver

      expect(Order.find_by_code(order_code).present?).to be_truthy
      expect_widget_presence
    end
  end

  scenario 'failed' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_on 'Add'
    expect(page).to have_content 'Add order'
    expect_widget_presence

    fill_in('order[data][contractNumber]', with: invalid_contract_number)

    click_on 'Add'

    expect_widget_presence
    expect(page.find('#error_explanation')).to have_content "Attribute 'contractNumber' has the invalid value '#{invalid_contract_number}'"
  end

  scenario 'denied' do
    logout
    visit new_order_path

    expect(page).to have_content 'Sign in'
  end
end
