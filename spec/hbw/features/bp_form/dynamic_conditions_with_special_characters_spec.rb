feature 'Dynamic conditions', js: true do
  before(:each) do
    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-34')
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_and_wait 'ORD-34'

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
