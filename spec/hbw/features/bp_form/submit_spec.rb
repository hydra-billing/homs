feature 'Submit form', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/bp_form/submit_mock.yml')

    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type)
  end

  scenario 'valid form will be submitted ' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-1'

    fill_in 'homsOrderDataAddress', with: 'test address'
    fill_in 'homsOrderDataHomePlace', with: 'test home place'

    expect(page).to have_selector "button[type='submit']"

    click_and_wait 'Submit'

    expect(page).not_to have_content 'Field does not match regex'
    expect(page).not_to have_content 'Field is required'

    expect_widget_presence
  end
end
