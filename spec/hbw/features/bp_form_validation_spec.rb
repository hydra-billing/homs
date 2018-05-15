feature 'Validate form', js: true do
  before(:each) do
    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
  end

  scenario 'invalid form is not submitted' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-1'

    expect(page).to have_selector "[name='homsOrderDataAddress']"
    expect(page).to have_selector "button[type='submit']"

    click_and_wait 'Submit'
    expect(page).to have_content 'Поле обязательное'
  end
end
