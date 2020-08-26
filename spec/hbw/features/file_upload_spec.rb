feature 'Check file upload field with', js: true do
  before(:each) do
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-15')
  end

  scenario 'file list field missing should have warning' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait ('ORD-15')

    expect(page).to have_content  'ORD-15'
    expect(page).to have_selector "[name='homsOrderDataUploadedFile']"
    expect(page).to have_content  'To load files please add a field of file_list type with the name homsOrderDataFileList'
    expect_widget_presence
  end
end
