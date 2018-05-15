feature 'Check select table with', js: true do
  before(:each) do
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-14')
  end

  scenario 'shows table with static variants' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-14'

    expect(page).to have_content  'ORD-14'

    expect(page).to have_content 'Name'
    expect(page).to have_content 'Code'
    expect(page).to have_content 'Arbitrary number'

    expect(page).to have_content 'My favourite region name'
    expect(page).to have_content 'My favourite region code'
    expect(page).to have_content '235,234,521.00'

    expect(page).to have_content 'My favourite region name2'
    expect(page).to have_content 'My favourite region code2'
    expect(page).to have_content '3,252,349,284.00'

    expect_widget_presence
  end
end
