feature 'Validate form', js: true do
  before(:each) do
    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-14')
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-16')
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-33')
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders'
  end

  describe 'form should not be submitted' do
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

    scenario 'with empty required multi select table' do
      click_and_wait 'ORD-16'

      expect(page).to have_content 'Options'
      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field is required'
    end
  end

  describe 'form should be submitted' do
    scenario 'with hidden and disabled not valid fields' do
      click_and_wait 'ORD-33'

      fill_in 'submittedString', with: 'act'

      expect(page).not_to have_content 'Hidden string'
      expect(page).not_to have_content 'Hidden select'
      expect(page).not_to have_content 'Hidden select_table'

      expect(readonly?('disabledString')).to         be true
      expect(page.find('.disabled-select')).to       have_selector '.react-select--is-disabled'
      expect(page.find('.disabled-select-table')).to have_selector '.disabled'

      expect(page).to have_selector "button[type='submit']"
      click_and_wait 'Submit'
    end
  end
end
