feature 'Edit order', js: true do
  let(:contract_number)  { '123456' }
  let(:problem_descr)    { 'Problem description' }
  let(:order_code)       { 'ORD-1' }
  let(:current_date)     { Date.today.strftime('%m/%d/%Y') }
  let(:current_date_iso) { Date.today.iso8601 }

  before(:each) do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryGirl.create(:order_type, :support_request)
    FactoryGirl.create(:order, order_type: order_type)
  end

  scenario 'success' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait(order_code)
    expect(page).to have_content order_code
    expect_widget_presence

    click_on_icon 'fa.fa-pencil'

    page.has_css?('.order-edit-form', wait: 5, visible: true)
    expect(page).to have_content order_code
    expect_widget_presence

    expect(page).to have_css('.order_data_creationDate')
    click_on_calendar('order_data_creationDate')
    click_checkbox_div('order_data_callBack')
    fill_in('order[data][problemDescription]', with: problem_descr)
    fill_in('order[data][contractNumber]',     with: contract_number)
    click_and_wait('Update Order')

    expect(page).to                                 have_content order_code
    expect(find_by_title('Creation date')).to       have_content current_date
    expect(find_by_title('Contract number')).to     have_content contract_number
    expect(find_by_title('Problem description')).to have_content problem_descr
    expect(find_by_title('Callback').first('.fa-check')).not_to  eq(nil)

    expect(Order.find_by_code(order_code).data['callBack']).to           be_truthy
    expect(Order.find_by_code(order_code).data['creationDate']).to       include(current_date_iso)
    expect(Order.find_by_code(order_code).data['contractNumber']).to     eq(contract_number.to_i)
    expect(Order.find_by_code(order_code).data['problemDescription']).to eq(problem_descr)

    expect_widget_presence
  end

  scenario 'denied' do
    logout
    visit edit_order_path(order_code)

    expect(page).to have_content 'Sign in'
  end
end
