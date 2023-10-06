feature 'Submit form', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/bp_form/submit_disabled_fields_mock.yml')

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type:) # ORD-1
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_and_wait 'ORD-1'

    expect(page).to have_selector "[name='submittedString']"
  end

  scenario 'disabled fields should not be submitted' do
    fill_in 'submittedString', with: '111'

    expect(page).to have_selector "button[type='submit']"

    click_and_wait 'Submit'

    expect_widget_presence
  end
end
