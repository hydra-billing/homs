feature 'Show business process form', js: true do
  let(:contract_number)  { '123456' }
  let(:problem_descr)    { 'Problem description' }
  let(:current_date)     { Date.today.strftime('%m/%d/%Y') }
  let(:current_date_iso) { Date.today.iso8601 }

  before(:each) do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryGirl.create(:order_type, :support_request)
    FactoryGirl.create(:order, order_type: order_type)
    FactoryGirl.create(:order, order_type: order_type)
  end

  scenario 'check select options' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait('ORD-1')

    expect(page).to                                  have_selector("[name='homsOrderDataSelect']")
    expect(page).to                                  have_content 'ORD-1'
    expect(select2_text('homsOrderDataSelect')).to   eq 'Option 1'
    expect(select_options('homsOrderDataSelect')).to eq ['Not selected', 'Option 1', 'Option 2']
    expect(select_values('homsOrderDataSelect')).to  eq ['', '123456', '654321']
    expect_widget_presence
  end

  scenario 'check select options from BP variable' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait('ORD-2')

    expect(page).to                                  have_selector("[name='homsOrderDataSelect']")
    expect(page).to                                  have_content 'ORD-2'
    expect(select2_text('homsOrderDataSelect')).to   eq 'Option Var 1'
    expect(select_options('homsOrderDataSelect')).to eq ['Not selected', 'Option Var 1', 'Option Var 2']
    expect(select_values('homsOrderDataSelect')).to  eq ['', '123', '321']
    expect_widget_presence
  end
end
