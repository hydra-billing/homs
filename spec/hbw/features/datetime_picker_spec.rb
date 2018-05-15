feature 'Check datetime picker with', js: true do
  let(:order_code) { 'ORD-1' }
  let(:nav_button) { 'Orders' }
  let(:title)      { 'Orders list' }

  before(:each) do
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type: order_type)

    click_on nav_button
    expect(page).to have_content title
    expect_widget_presence

    click_and_wait(order_code)
    expect_widget_presence
    expect(page).to have_content order_code
  end

  scenario 'en locale as default' do
    expect(page).to have_content 'Begin Date'
    expect(bp_calendar_value('BeginDate')).to eq('09/30/2016')

    click_on_bp_calendar('BeginDate')
    expect(page).to have_content 'September 2016'
  end

  scenario 'ru locale' do
    expect(page).to have_content 'End Date'
    expect(bp_calendar_value('EndDate')).to eq('30.09.2016')

    click_on_bp_calendar('EndDate')
    expect(page).to have_content 'сентябрь 2016'
  end
end
