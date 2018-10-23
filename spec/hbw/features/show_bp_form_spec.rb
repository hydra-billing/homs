feature 'Show business process form', js: true do
  before(:each) do
    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-13')
  end

  scenario 'check select options' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-1'

    expect(page).to have_content 'ORD-1'
    expect_r_select_presence('homsOrderDataSelect')
    expect(r_select_single_value('homsOrderDataSelect')).to eq({label: 'Option 1', value: '123456'})

    set_r_select_option('homsOrderDataSelect', 'Option 2')

    expect(r_select_single_value('homsOrderDataSelect')).to eq({label: 'Option 2', value: '654321'})
    expect_widget_presence
  end

  scenario 'check select options from BP variable' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-2'

    expect(page).to have_content 'ORD-2'
    expect_r_select_presence('homsOrderDataSelect')
    expect(r_select_single_value('homsOrderDataSelect')).to eq({label: 'Option Var 1', value: '123'})

    set_r_select_option('homsOrderDataSelect', 'Option Var 2')

    expect(r_select_single_value('homsOrderDataSelect')).to eq({label: 'Option Var 2', value: '321'})
    expect_widget_presence
  end

  scenario 'check select options from billing source' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-13'

    expect(page).to have_content 'ORD-13'
    expect_r_select_presence('homsOrderDataSelect')

    r_select_input('homsOrderDataSelect').set('cust')
    wait_for_ajax

    expect(page).to have_content 'Found customer'
    expect(r_select_lookup_options('homsOrderDataSelect')).to eq ['Found customer']

    expect_widget_presence
  end
end
