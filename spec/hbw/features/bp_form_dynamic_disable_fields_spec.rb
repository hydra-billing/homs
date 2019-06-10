feature 'Control dynamic disable string on form', js: true do
  before(:each) do
    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-18')

    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-18'

    expect(page).to have_selector "[name='homsOrderCheckingThis']"
  end

  scenario 'AND & OR conditions for string' do
    expect(find_by_name('homsOrderAndEnableAfterChanges').readonly?).to  eq true
    expect(find_by_name('homsOrderAndDisableAfterChanges').readonly?).to eq false
    expect(find_by_name('homsOrderOrEnableAfterChanges').readonly?).to   eq true
    expect(find_by_name('homsOrderOrDisableAfterChanges').readonly?).to  eq false

    fill_in 'homsOrderCheckingThis', with: '1234'

    expect(find_by_name('homsOrderAndEnableAfterChanges').readonly?).to  eq false
    expect(find_by_name('homsOrderAndDisableAfterChanges').readonly?).to eq true
    expect(find_by_name('homsOrderOrEnableAfterChanges').readonly?).to   eq false
    expect(find_by_name('homsOrderOrDisableAfterChanges').readonly?).to  eq true

    expect(page).to have_selector "button[type='submit']"
    click_and_wait 'Submit'

    expect_widget_presence
  end
end
