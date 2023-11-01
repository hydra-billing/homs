feature 'Check services select table', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/bp_form/services_select_mock.yml')

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type:) # ORD-1
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_and_wait 'ORD-1'
  end

  scenario 'should contain required subscriptions' do
    # Table content
    expect(page).to have_content 'Terminal equipment'
    expect(page).to have_content 'Employee'
    expect(page).to have_content '310000'
    expect(page).to have_content '3 pcs'
    expect(page).to have_content '930000'
    expect(page).to have_content '01.10.2023 09:10:82'
    expect(page).to have_content 'Some address here, apt. 1, floor 12'
    expect(page).to have_content '00-B0-D0-63-C2-26'
    expect(page).to have_content '192.168.1.1'
    expect(page).to have_content '88005553535'

    # Search option
    expect(page).to have_selector '.input-wrapper'
    fill_in 'Search', with: 'Offre'
    expect(page).to have_content 'Offre Residence'
    expect(page).not_to have_content 'Employee'
    fill_in 'Search', with: ''

    # Columns setting option
    expect_r_multi_select_presence('react-select-container')
    options = ['Amount', 'Service address']
    set_r_multi_select_options('react-select-container', options)
    expect(page).not_to have_content '3 pcs'
    expect(page).not_to have_content 'Some address here, apt. 1, floor 12'
  end
end
