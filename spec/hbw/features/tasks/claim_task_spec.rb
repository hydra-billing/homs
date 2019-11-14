feature 'Check task claiming', js: true do
  before(:each) do
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-1')
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-23')
  end

  describe 'form with all fields' do
    before(:each) do
      click_on 'Orders'
      expect(page).to have_content 'Orders list'
      expect_widget_presence
    end

    scenario 'have only disabled or readonly fields' do
      click_and_wait 'ORD-23'

      find_form.find_all('input').each do |input|
        expect(input.disabled? || input.readonly?).to eq true
      end
    end

    scenario 'can be claimed' do
      click_and_wait 'ORD-23'

      expect(page).not_to have_content 'Submit'

      click_and_wait('Claim')
    end

    scenario 'does not have "Claim" button if assigned' do
      click_and_wait 'ORD-1'

      expect(page).not_to have_content 'Orders list'
      expect(page).not_to have_content 'Claim'
    end
  end
end
