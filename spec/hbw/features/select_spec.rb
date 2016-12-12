feature 'Check select with', js: true do
  let(:placeholder) { 'placeholder' }
  let(:first_value) { 'Option 1' }

  before(:each) do
    user = FactoryGirl.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryGirl.create(:order_type, :support_request)

    FactoryGirl.create(:order, order_type: order_type)
    FactoryGirl.create(:order, order_type: order_type)
    FactoryGirl.create(:order, order_type: order_type)
    FactoryGirl.create(:order, order_type: order_type)
    FactoryGirl.create(:order, order_type: order_type)
    FactoryGirl.create(:order, order_type: order_type)
    FactoryGirl.create(:order, order_type: order_type)
    FactoryGirl.create(:order, order_type: order_type)
    FactoryGirl.create(:order, order_type: order_type)
    FactoryGirl.create(:order, order_type: order_type).update(code: 'ORD-12')
  end

  scenario 'nullable = true and placeholder present' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-3'

    expect(page).to have_content  'ORD-3'
    expect(page).to have_selector "[name='homsOrderDataSelect']"
    expect(select2_text('homsOrderDataSelect')).to eq placeholder
    expect_widget_presence
  end

  scenario 'nullable = false and placeholder present' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-4'

    expect(page).to have_content  'ORD-4'
    expect(page).to have_selector "[name='homsOrderDataSelect']"
    expect(select2_text('homsOrderDataSelect')).to eq first_value
    expect_widget_presence
  end

  scenario 'nullable = true and placeholder blank' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-5'

    expect(page).to have_content  'ORD-5'
    expect(page).to have_selector "[name='homsOrderDataSelect']"
    expect(select2_text('homsOrderDataSelect')).to eq 'Not selected'
    expect_widget_presence
  end

  scenario 'nullable = false and placeholder blank' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-6'

    expect(page).to have_content  'ORD-6'
    expect(page).to have_selector "[name='homsOrderDataSelect']"
    expect(select2_text('homsOrderDataSelect')).to eq first_value
    expect_widget_presence
  end

  scenario 'defining choices as arrays' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-7'

    expect(page).to have_content  'ORD-7'
    expect(page).to have_selector "[name='homsOrderDataSelect']"
    expect(select2_text('homsOrderDataSelect')).to   eq first_value
    expect(select_options('homsOrderDataSelect')).to eq ['Option 1', 'Option 2']
    expect(select_values('homsOrderDataSelect')).to  eq ['112233', '445566']
    expect_widget_presence
  end

  scenario 'defining choices as strings' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-8'

    expect(page).to have_content  'ORD-8'
    expect(page).to have_selector "[name='homsOrderDataSelect']"
    expect(select2_text('homsOrderDataSelect')).to   eq first_value
    expect(select_options('homsOrderDataSelect')).to eq ['Option 1', 'Option 2']
    expect(select_values('homsOrderDataSelect')).to  eq ['Option 1', 'Option 2']
    expect_widget_presence
  end

  scenario 'field name not defined in BP variables' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-9'

    expect(page).to have_content  'ORD-9'
    expect(page).to have_selector "[name='homsOrderNotInVBPVariables']"
    expect(page).to have_content  'Field with name homsOrderNotInVBPVariables not defined in BP variables'
    expect_widget_presence
    end

  scenario 'BP variable value is null for required field' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait ('ORD-12')

    expect(page).to have_content 'ORD-12'
    expect(page).to have_selector("[name='homsOrderDataSelect']")
    expect(select2_text('homsOrderDataSelect')).to eq first_value
    expect(page).to have_no_content 'Field with name homsOrderNotInVBPVariables not defined in BP variables'
    expect_widget_presence
  end
end
