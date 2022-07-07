feature 'Check BP start button', js: true do
  let(:order_code) { 'ORD-1' }

  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/bp_start_button_mock.yml')

    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type: order_type)
  end

  scenario 'show with candidate_starters disabled' do
    set_candidate_starters(false)

    click_on 'Orders'
    expect(page).to have_content 'Orders list'

    click_and_wait 'ORD-1'

    expect(page).to have_content 'ORD-1'

    expect(page).to have_content 'Support Request'
  end

  scenario 'hide with candidate_starters enabled' do
    set_candidate_starters(true)

    click_on 'Orders'
    expect(page).to have_content 'Orders list'

    click_and_wait 'ORD-1'

    expect(page).to have_content 'ORD-1'

    expect(page).not_to have_content 'Support Request'

    expect(page).to have_content 'There are no business processes available to start.'
  end
end
