feature 'Check static field', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/static_mock.yml')

    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
  end

  scenario 'with single substitution' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-1'

    expect(page).to have_content 'ORD-1'
    expect(page).to have_content 'TEST STATIC ORD-1'
    expect_widget_presence
  end

  scenario 'with multiple substitutions' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-2'

    expect(page).to have_content 'ORD-2'
    expect(page).to have_content '123 TEST STATIC ORD-2'
    expect_widget_presence
  end

  scenario 'with wrong substitutions' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-3'

    expect(page).to have_content 'ORD-3'
    expect(page).to have_content '$wrongBPVariable TEST STATIC $wrongBPVariable'
    expect_widget_presence
  end

  scenario 'with same substitution' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-4'

    expect(page).to have_content 'ORD-4'
    expect(page).to have_content 'ORD-4 TEST STATIC ORD-4'
    expect_widget_presence
  end
end
