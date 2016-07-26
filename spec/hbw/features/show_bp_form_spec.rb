feature 'Show business process form', js: true do
  let(:contract_number)  { '123456' }
  let(:problem_descr)    { 'Problem description' }
  let(:order_code)       { 'ORD-1' }
  let(:current_date)     { Date.today.strftime('%m/%d/%Y') }
  let(:current_date_iso) { Date.today.iso8601 }

  before(:each) do
    OrderSequenceService.new.destroy
    OrderSequenceService.new.create

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
    widget_exist?

    click_on order_code
    expect(page).to have_selector("[name='homsOrderDataSelect']")

    expect(select2_text('homsOrderDataSelect')).to   eq 'Option 1'
    expect(select_options('homsOrderDataSelect')).to eq ['Not selected', 'Option 1', 'Option 2']
    expect(select_values('homsOrderDataSelect')).to  eq ['', '123456', '654321']

    expect(page).to have_content order_code
    widget_exist?
  end
end
