feature 'Check description on top and botton of checkbox', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/bp_form/radio_button_mock.yml')

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type) # ORD-1
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_and_wait 'ORD-1'
  end

  scenario 'should contain a top and bottom checkbox descriptions' do
    parent_top = page.find('.radiobutton-top')
    expect(page).to have_selector "[name='radioButton']", visible: false
    expect(find_by_dt('description-top', parent_top).text).to eq 'Top description test'
  end
end
