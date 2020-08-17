feature 'Print', js: true do
  include DownloadHelper

  let(:first_order_code)  { 'ORD-1' }
  let(:second_order_code) { 'ORD-2' }

  before(:each) do
    clear_downloads

    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
  end

  # HOMS-288
  # scenario 'single file' do
  #   click_on 'Orders'
  #   expect(page).to have_content 'Orders list'
  #   expect_widget_presence
  #
  #   click_and_wait(first_order_code)
  #   expect(page).to have_content first_order_code
  #   expect_widget_presence
  #
  #   click_on_icon 'fas.fa-print'
  #
  #   expect(page).to have_selector('.print-dropdown .dropdown-menu', visible: true, wait: 5)
  #
  #   click_and_wait('Print')
  #   wait_for_download
  #
  #   aggregate_failures 'check downloaded file' do
  #     expect(downloads.count).to eq 1
  #     expect(download.include?('test_1.txt')).to be_truthy
  #     expect(download_content).to eq 'substitution 1'
  #   end
  #
  #   page.driver.go_back
  #   expect_widget_presence
  # end

  scenario 'multiple files' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    expect(page).to have_content first_order_code
    expect(page).to have_content second_order_code
    expect(page).to have_content 'Print'

    click_and_wait('Print')

    expect(page).to have_content 'Print task 123 processing started. Please check your email for result.'
  end

  scenario 'denied' do
    logout
    visit edit_order_path(first_order_code)

    expect(page).to have_content 'Sign in'
  end
end
