feature 'Create new order', js: true do
  let(:contract_number)         { '123456' }
  let(:invalid_contract_number) { 'qwerty' }
  let(:problem_descr)           { 'Problem description' }
  let(:order_code)              { 'ORD-1' }
  let(:current_date)            { Date.today.strftime('%m/%d/%Y') }

  before(:each) do
    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    FactoryBot.create(:order_type, :support_request)
  end

  scenario 'success' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_on 'Add'
    expect(page).to have_content 'Adding order'
    expect_widget_presence

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
    expect(Order.find_by_code('ORD-1').present?).to              be_truthy
    expect_widget_presence
  end

  scenario 'failed' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_on 'Add'
    expect(page).to have_content 'Adding order'
    expect_widget_presence

    fill_in('order[data][contractNumber]', with: invalid_contract_number)

    click_on 'Add'

    expect_widget_presence
    expect(page.find('#error_explanation')).to have_content "Attribute 'contractNumber' has invalid value '#{invalid_contract_number}'"
  end

  scenario 'denied' do
    logout
    visit new_order_path

    expect(page).to have_content 'Sign in'
  end
end
