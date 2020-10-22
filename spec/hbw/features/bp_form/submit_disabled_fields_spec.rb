feature 'Submit form', js: true do
  before(:each) do
    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-28')
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_and_wait 'ORD-28'

    expect(page).to have_selector "[name='submittedString']"
  end

  scenario 'disabled fields should not be submitted' do
    fill_in 'submittedString', with: '111'

    expect(page).to have_selector "button[type='submit']"

    click_and_wait 'Submit'

    expect_widget_presence
  end
end
