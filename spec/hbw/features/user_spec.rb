feature 'Check user picker', js: true do
  let(:placeholder) { 'placeholder' }

  before(:each) do
    user = FactoryBot.create(:user)
    FactoryBot.create(:user, :john)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-10')
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-11')
  end

  scenario 'with placeholder' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-10'

    expect(page).to have_content  'ORD-10'
    expect(page).to have_selector "[name='homsOrderWhatUser']"
    expect(select2_text('homsOrderWhatUser')).to eq placeholder
    expect_widget_presence
  end

  scenario 'lookup user' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-10'

    expect(page).to have_content  'ORD-10'
    expect(page).to have_selector "[name='homsOrderWhatUser']"
    select2_text_node('homsOrderWhatUser').click
    select2_search_field.set('John')
    wait_for_ajax

    expect(page).to have_content 'John Doe'
    expect(page).to have_content 'Christopher Johnson'
    expect_widget_presence
  end

  scenario 'select user for nullable field' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-10'

    expect(page).to have_content  'ORD-10'
    expect(page).to have_selector "[name='homsOrderWhatUser']"
    select2_text_node('homsOrderWhatUser').click
    select2_search_field.set('John')
    wait_for_ajax

    choose_select2_option('John Doe').click
    expect(select2_text('homsOrderWhatUser')).to eq 'John Doe'
    select2_clear_cross('homsOrderWhatUser').click
    expect(select2_value('homsOrderWhatUser')).to eq ''
    expect_widget_presence
  end

  scenario 'select user for required field' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-11'

    expect(page).to have_content  'ORD-11'
    expect(page).to have_selector "[name='homsOrderWhatUser']"
    select2_text_node('homsOrderWhatUser').click
    select2_search_field.set('John')
    wait_for_ajax

    choose_select2_option('John Doe').click
    expect(select2_text('homsOrderWhatUser')).to  eq 'John Doe'
    expect(select2_value('homsOrderWhatUser')).to eq '2'
    select2_no_clear('homsOrderWhatUser')
    expect_widget_presence
  end
end
