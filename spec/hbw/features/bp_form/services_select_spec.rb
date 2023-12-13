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
    expect(page).to have_content '01.10.2023'
    expect(page).to have_content 'Some address here, apt. 1, floor 12'
    expect(page).to have_content '00-B0-D0-63-C2-26'
    expect(page).to have_content '192.168.1.1'
    expect(page).to have_content '88005553535'
  end

  scenario 'search' do
    expect(page).to have_selector '.input-wrapper'
    fill_in 'Search', with: 'Offre'
    expect(page).to have_content 'Offre Residence'
    expect(page).not_to have_content 'Employee'
    fill_in 'Search', with: ''
  end

  scenario 'columns display setting' do
    expect_r_multi_select_presence('react-select-container')
    options = ['Amount', 'Service address']
    set_r_multi_select_options('react-select-container', options)
    expect(page).not_to have_content '3 pcs'
    expect(page).not_to have_content 'Some address here, apt. 1, floor 12'
  end

  scenario 'add service' do
    # Check modal controls
    expect(page).to have_selector '.add-service-button'
    page.find_all('.add-service-button').first.click
    expect(page).to have_content 'Service add'
    expect(page).to have_content 'Enable service'
    page.find('.close-add-service-button').click
    expect(page).not_to have_content 'Enable service'

    # Add new service
    page.find_all('.add-service-button').first.click
    set_r_select_option('service-select', 'Individual')
    fill_in_datetime_field 'start-date-visible-input', with: '08.11.2019'
    fill_in_datetime_field 'end-date-visible-input', with: '08.11.2023'
    fill_in 'quantity', with: '5'
    page.find('.submit-add-service-button').click
    expect(page).to have_content 'Individual'
    expect(page).to have_content '2.11'
    expect(page).to have_content '5 pcs'
    expect(page).to have_content '10.55'
    expect(page).to have_content '08.11.2019'
    expect(page).to have_content '08.11.2023'
  end
end
