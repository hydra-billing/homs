feature 'Dynamic conditions', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/bp_form/dynamic_conditions_with_special_characters_mock.yml')

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type:) # ORD-1
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_and_wait 'ORD-1'

    expect(page).to have_selector "[name='controlString']"
  end

  scenario 'should work correctly with double quotes' do
    expect(page).to have_content 'String with quotes'

    fill_in 'controlString', with: 'ООО "ЛАТЕРА"'

    expect(page).not_to have_content 'String with quotes'
  end

  scenario 'should work correctly with single quotes' do
    expect(readonly?('stringWithQuotes')).to be false

    fill_in 'controlString', with: "Some 'text'"

    expect(readonly?('stringWithQuotes')).to be true
  end

  scenario 'should work correctly with backslash' do
    expect(readonly?('stringWithBackslash')).to be false

    fill_in 'controlString', with: 'Account-45673\RTK'

    expect(readonly?('stringWithBackslash')).to be true
  end
end
