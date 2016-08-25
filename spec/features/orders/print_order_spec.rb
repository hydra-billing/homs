feature 'Print', js: true do
  let(:order_code)       { 'ORD-1' }

  before(:each) do
    OrderSequenceService.new.destroy
    OrderSequenceService.new.create

    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryGirl.create(:order_type, :support_request)
    FactoryGirl.create(:order, order_type: order_type)
  end

  scenario 'single file' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_on order_code
    expect(page).to have_content order_code
    expect_widget_presence

    click_on_icon 'fa.fa-print'

    expect(page).to have_selector('.print-dropdown .dropdown-menu', visible: true)

    click_on 'Print'

    expect(page.response_headers['Content-Type']).to eq 'text/plain'
    expect(page.response_headers['Content-Disposition']).to eq "attachment; filename*=UTF-8''test_1.txt"
    expect_widget_presence
  end

  scenario 'denied' do
    logout
    visit edit_order_path(order_code)

    expect(page).to have_content 'Sign in'
  end
end
