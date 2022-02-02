feature 'Control fields on form', js: true do
  before(:each) do
    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type)

    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-1'

    expect(page).to have_selector "[name='homsOrderDataAddress']"
  end

  scenario 'disable for AND-condition for string' do
    expect(find_by_name('homsOrderDataWorkAddress').readonly?).to eq true
  end

  scenario 'enable for AND-condition' do
    expect(find_by_name('homsOrderDataAddress').readonly?).to eq false
  end

  scenario 'disable for OR-condition for datetime' do
    expect(find_by_name('homsOrderDataDisabledEndDate').disabled?).to eq true
  end

  scenario 'enable for OR-condition' do
    expect(find_by_name('homsOrderDataRecommendation').disabled?).to eq false
  end

  scenario 'for checkbox' do
    expect(is_element('homsOrderDataSomeDisabledCheckbox', true)).to eq true
  end

  scenario 'for select' do
    expect(page.find('.my-disabled-select')).to have_selector '.react-select--is-disabled'
  end

  scenario 'for text' do
    expect(find_by_name('homsOrderDataSomeDisabledText').readonly?).to eq true
  end
end
