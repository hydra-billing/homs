feature 'Check radiobutton', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/bp_form/radio_button_icon_mock.yml')

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type) # ORD-1
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_and_wait 'ORD-1'
  end

  scenario 'should contain fas and far icons' do
    parent_top = page.find('.hbw-radio-label')

    expect(page).to have_selector '.fa-circle'
    expect(parent_top.find(:dp, 'far')).to eq parent_top.find(:di, 'circle')

    click_on_checkbox_by_name('testRadioIcon')

    expect(parent_top.find(:dp, 'fas')).to eq parent_top.find(:di, 'square')
  end
end
