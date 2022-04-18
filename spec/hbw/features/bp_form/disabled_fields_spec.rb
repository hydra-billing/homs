feature 'Control fields on form', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/bp_form/disabled_fields_mock.yml')

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
    expect(find_by_name('homsOrderDataDisabledEndDate-visible-input').disabled?).to eq true
  end

  scenario 'enable for OR-condition' do
    expect(find_by_name('homsOrderDataRecommendation').disabled?).to eq false
  end

  scenario 'for checkbox' do
    expect(is_element('homsOrderDataSomeDisabledCheckbox', disabled: true)).to eq true
  end

  scenario 'for select' do
    expect(page.find('.my-disabled-select')).to have_selector '.react-select--is-disabled'
  end

  scenario 'for text' do
    expect(find_by_name('homsOrderDataSomeDisabledText').readonly?).to eq true
  end

  scenario 'for submit_select' do
    in_group_with_label('submit_select to be disabled group') do |group|
      group.find_button('Button 1', disabled: true)
      group.find_button('Button 2', disabled: true)
    end

    in_group_with_label('submit_select to be enabled group') do |group|
      group.find_button('Button 1', disabled: false)
      group.find_button('Button 2', disabled: false)
    end

    in_group_with_label('submit_select buttons to be disabled group') do |group|
      group.find_button('Disabled button', disabled: true)
      group.find_button('Enabled button',  disabled: false)
    end
  end
end
