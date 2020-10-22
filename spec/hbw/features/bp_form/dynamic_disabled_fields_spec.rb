feature 'Dynamic control fields on form', js: true do
  before(:each) do
    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-25')
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_and_wait 'ORD-25'

    expect(page).to have_selector "[name='homsOrderCheckingThis']"
  end

  scenario 'should be disabled for AND & OR conditions' do
    expect(readonly?('homsOrderAndEnabledAfterChanges')).to  be true
    expect(readonly?('homsOrderAndDisabledAfterChanges')).to be false
    expect(readonly?('homsOrderOrEnabledAfterChanges')).to   be true
    expect(readonly?('homsOrderOrDisabledAfterChanges')).to  be false

    fill_in 'homsOrderCheckingThis', with: '1234'

    expect(readonly?('homsOrderAndEnabledAfterChanges')).to  be false
    expect(readonly?('homsOrderAndDisabledAfterChanges')).to be true
    expect(readonly?('homsOrderOrEnabledAfterChanges')).to   be false
    expect(readonly?('homsOrderOrDisabledAfterChanges')).to  be true
  end
end
