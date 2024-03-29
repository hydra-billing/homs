feature 'Check user picker', js: true do
  let(:placeholder) { 'placeholder' }

  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/user_mock.yml')

    user = FactoryBot.create(:user)
    FactoryBot.create(:user, :john)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type:) # ORD-1
    FactoryBot.create(:order, order_type:) # ORD-2
  end

  scenario 'with placeholder' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-1'

    expect(page).to have_content 'ORD-1'
    expect_r_select_presence('homsOrderWhatUser')
    expect(r_select_placeholder('homsOrderWhatUser')).to eq placeholder
    expect_widget_presence
  end

  scenario 'lookup user' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-1'

    expect(page).to have_content 'ORD-1'
    expect_r_select_presence('homsOrderWhatUser')
    r_select_input('homsOrderWhatUser').set('John')
    wait_for_ajax

    expect(r_select_lookup_options('homsOrderWhatUser')).to eq ['John Doe', 'Christopher Johnson']
    expect_widget_presence
  end

  scenario 'select user for nullable field' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-1'

    expect(page).to have_content 'ORD-1'
    expect_r_select_presence('homsOrderWhatUser')
    r_select_input('homsOrderWhatUser').set('John')
    wait_for_ajax

    set_r_select_lookup_option('homsOrderWhatUser', 'John Doe')
    expect(r_select_single_value('homsOrderWhatUser')[:label]).to eq 'John Doe'

    r_select_clear_value('homsOrderWhatUser')
    ensure_r_select_is_empty('homsOrderWhatUser')
    expect_widget_presence
  end

  scenario 'select user for required field' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-2'

    expect(page).to have_content 'ORD-2'
    expect_r_select_presence('homsOrderWhatUser')
    r_select_input('homsOrderWhatUser').set('John')
    wait_for_ajax

    set_r_select_lookup_option('homsOrderWhatUser', 'John Doe')
    expect(r_select_single_value('homsOrderWhatUser')[:label]).to eq('John Doe')
    ensure_r_select_unclearable('homsOrderWhatUser')
    expect_widget_presence
  end
end
