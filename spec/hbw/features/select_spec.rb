feature 'Check select with', js: true do
  let(:placeholder)           { 'placeholder' }
  let(:first_value)           { 'Option 1' }

  before(:each) do
    OrderSequenceService.new.destroy
    OrderSequenceService.new.create

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
  end

  scenario 'nullable = true and placeholder present' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_on 'ORD-3'

    expect(page).to have_content 'ORD-3'

    expect(page).to have_selector("[name='homsOrderDataSelect']")
    expect(select2_text('homsOrderDataSelect')).to eq placeholder
    expect_widget_presence
  end

  scenario 'nullable = false and placeholder present' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_on 'ORD-4'

    expect(page).to have_content 'ORD-4'
    expect(page).to have_selector("[name='homsOrderDataSelect']")
    expect(select2_text('homsOrderDataSelect')).to eq first_value
    expect_widget_presence
  end

  scenario 'nullable = true and placeholder blank' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_on 'ORD-5'

    expect(page).to have_content 'ORD-5'
    expect(page).to have_selector("[name='homsOrderDataSelect']")
    expect(select2_text('homsOrderDataSelect')).to eq 'Not selected'
    expect_widget_presence
  end

  scenario 'nullable = false and placeholder blank' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_on 'ORD-6'

    expect(page).to have_content 'ORD-6'
    expect(page).to have_selector("[name='homsOrderDataSelect']")
    expect(select2_text('homsOrderDataSelect')).to eq first_value
    expect_widget_presence
  end
end
