feature 'Validate form', js: true do
  before(:each) do
    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-14')
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-16')
  end

  describe 'form is not submitted' do
    before(:each) do
      click_on 'Orders'
      expect(page).to have_content 'Orders list'
      expect_widget_presence
    end

    scenario 'with invalid regex field' do
      click_and_wait 'ORD-1'

      expect(page).to have_selector "[name='homsOrderDataAddress']"
      expect(page).to have_selector "[name='homsOrderDataHomePlace']"
      expect(page).to have_selector "button[type='submit']"

      fill_in 'homsOrderDataHomePlace', with: 'required field filled'

      click_and_wait 'Submit'

      expect(page).to have_content 'Field does not match regex'
      expect(page).not_to have_content 'Field is required'
    end

    scenario 'with empty required text input' do
      click_and_wait 'ORD-1'

      expect(page).to have_selector "[name='homsOrderDataAddress']"
      expect(page).to have_selector "[name='homsOrderDataHomePlace']"
      expect(page).to have_selector "button[type='submit']"

      fill_in 'homsOrderDataAddress', with: 'regex field filled properly'

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field does not match regex'
      expect(page).to     have_content 'Field is required'
    end

    scenario 'with empty required select table' do
      click_and_wait 'ORD-14'

      expect(page).to have_content 'Options'
      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).to have_content 'Field is required'
    end

    scenario 'with empty required multi select table' do
      click_and_wait 'ORD-16'
      click_td_by_text 'My favourite region name1'

      expect(page).to have_content 'Options'
      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field is required'
    end
  end
end
