feature 'Check select with', js: true do
  let(:placeholder) { 'placeholder' }
  let(:first_value) { 'Option 1' }

  before(:each) do
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-12')
  end

  scenario 'nullable = true and placeholder present' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-3'

    expect(page).to have_content 'ORD-3'
    expect_r_select_presence('homsOrderDataSelect')
    expect(r_select_placeholder('homsOrderDataSelect')).to eq placeholder
    expect_widget_presence
  end

  scenario 'nullable = false and placeholder present' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-4'

    expect(page).to have_content 'ORD-4'
    expect_r_select_presence('homsOrderDataSelect')
    expect(r_select_single_value('homsOrderDataSelect')[:label]).to eq first_value
    expect_widget_presence
  end

  scenario 'nullable = true and placeholder blank' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-5'

    expect(page).to have_content 'ORD-5'
    expect_r_select_presence('homsOrderDataSelect')
    expect(r_select_placeholder('homsOrderDataSelect')).to eq ''
    expect_widget_presence
  end

  scenario 'nullable = false and placeholder blank' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-6'

    expect(page).to have_content 'ORD-6'
    expect_r_select_presence('homsOrderDataSelect')
    expect(r_select_single_value('homsOrderDataSelect')[:label]).to eq first_value
    expect_widget_presence
  end

  scenario 'defining choices as arrays' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-7'

    expect(page).to have_content 'ORD-7'
    expect_r_select_presence('homsOrderDataSelect')
    expect(r_select_single_value('homsOrderDataSelect')).to eq({label: 'Option 1', value: '112233'})

    set_r_select_option('homsOrderDataSelect', 'Option 2')

    expect(r_select_single_value('homsOrderDataSelect')).to eq({label: 'Option 2', value: '445566'})
    expect_widget_presence
  end

  scenario 'defining choices as strings' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-8'

    expect(page).to have_content 'ORD-8'
    expect_r_select_presence('homsOrderDataSelect')
    expect(r_select_single_value('homsOrderDataSelect')).to eq({label: 'Option 1', value: 'Option 1'})

    set_r_select_option('homsOrderDataSelect', 'Option 2')

    expect(r_select_single_value('homsOrderDataSelect')).to eq({label: 'Option 2', value: 'Option 2'})
    expect_widget_presence
  end

  scenario 'field name not defined in BP variables' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-9'

    expect(page).to have_content 'ORD-9'
    expect_r_select_presence('homsOrderNotInVBPVariables')
    expect(page).to have_content 'Field with name homsOrderNotInVBPVariables not defined in BP variables'
    expect_widget_presence
  end

  scenario 'BP variable value is null for required field' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait ('ORD-12')

    expect(page).to have_content 'ORD-12'
    expect_r_select_presence('homsOrderDataSelect')
    expect(r_select_single_value('homsOrderDataSelect')[:label]).to eq first_value
    expect(page).to have_no_content 'Field with name homsOrderNotInVBPVariables not defined in BP variables'
    expect_widget_presence
  end
end
