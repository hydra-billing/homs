feature 'Validate form', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/bp_form/validation_mock.yml')

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type:)
    FactoryBot.create(:order, order_type:)
    FactoryBot.create(:order, order_type:)
    FactoryBot.create(:order, order_type:)
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
      click_and_wait 'ORD-2'

      expect(page).to have_content 'Options'
      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field is required'
    end

    scenario 'with not filled required radio button' do
      click_and_wait 'ORD-4'

      expect(page).to have_content 'Radio button label 1'
      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).to have_content 'Field is required'
    end
  end

  describe 'form should be submitted' do
    scenario 'with hidden and disabled not valid fields' do
      click_and_wait 'ORD-3'

      fill_in 'submittedString', with: 'act'

      expect(page).not_to have_content 'Hidden string'
      expect(page).not_to have_content 'Hidden select'
      expect(page).not_to have_content 'Hidden select_table'
      expect(page).not_to have_content 'Hidden radio button label 1'

      expect(readonly?('disabledString')).to         be true
      expect(page.find('.disabled-select')).to       have_selector '.react-select--is-disabled'
      expect(page.find('.disabled-select-table')).to have_selector '.disabled'
      expect(page).to                                have_selector '.hbw-radio-label.disabled'

      expect(page).to have_selector "button[type='submit']"
      click_and_wait 'Submit'
    end
  end
end
