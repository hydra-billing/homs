feature 'Dynamic control fields on form', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/bp_form/dynamic_hidden_fields_mock.yml')

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type:) # ORD-1
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_and_wait 'ORD-1'

    expect(page).to have_selector "[name='homsOrderCheckingThis']"
  end

  scenario 'should be hidden for AND & OR conditions' do
    expect(page).not_to have_selector "[name='homsOrderAndShownAfterChanges']"
    expect(page).to     have_selector "[name='homsOrderAndHiddenAfterChanges']"
    expect(page).not_to have_selector "[name='homsOrderOrShownAfterChanges']"
    expect(page).to     have_selector "[name='homsOrderOrHiddenAfterChanges']"

    fill_in 'homsOrderCheckingThis', with: '1234'

    expect(page).to     have_selector "[name='homsOrderAndShownAfterChanges']"
    expect(page).not_to have_selector "[name='homsOrderAndHiddenAfterChanges']"
    expect(page).to     have_selector "[name='homsOrderOrShownAfterChanges']"
    expect(page).not_to have_selector "[name='homsOrderOrHiddenAfterChanges']"
  end
end
