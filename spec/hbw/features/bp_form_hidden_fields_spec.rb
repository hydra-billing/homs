feature 'Control fields on form', js: true do
  before(:each) do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryGirl.create(:order_type, :support_request)
    FactoryGirl.create(:order, order_type: order_type)

    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-1'

    expect(page).to have_selector "[name='homsOrderDataAddress']"
  end

  scenario 'hide for AND-condition' do
    expect(page).not_to have_selector "[name='homsOrderDataWorkPlace']"
  end

  scenario 'show for AND-condition' do
    expect(page).to have_selector "[name='homsOrderDataHomePlace']"
  end

  scenario 'hide for OR-condition' do
    expect(page).not_to have_selector "[name='homsOrderDataReason']"
  end

  scenario 'show for OR-condition' do
    expect(page).to have_selector "[name='homsOrderDataRecommendation']"
  end

  scenario 'for checkbox' do
    expect(page).not_to have_selector '.my-checkbox'
  end

  scenario 'for datetime' do
    expect(page).not_to have_selector "[name='homsOrderDataSomeDatetime']"
  end

  scenario 'for group' do
    expect(page).not_to have_content 'Hidden group'
  end

  scenario 'for select' do
    expect(page).not_to have_selector '.my-select'
  end

  scenario 'for static' do
    expect(page).not_to have_content 'Some static'
  end

  scenario 'for string' do
    expect(page).not_to have_selector "[name='homsOrderDataSomeStr']"
  end

  scenario 'for text' do
    expect(page).not_to have_selector "[name='homsOrderDataSomeText']"
  end
end
