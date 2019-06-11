feature 'Select table', js: true do
  before(:each) do
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-14')
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-18')
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-19')
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-20')
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-21')
  end

  scenario 'rendered with static variants' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-14'

    expect(page).to have_content  'ORD-14'

    expect(page).to have_content 'Name'
    expect(page).to have_content 'Code'
    expect(page).to have_content 'Arbitrary number'

    expect(page).to have_content 'My favourite region name'
    expect(page).to have_content 'My favourite region code'
    expect(page).to have_content '235,234,521.00'

    expect(page).to have_content 'My favourite region name2'
    expect(page).to have_content 'My favourite region code2'
    expect(page).to have_content '3,252,349,284.00'

    expect_widget_presence
  end

  describe 'will be submitted if' do
    before(:each) do
      click_on 'Orders'
      expect(page).to have_content 'Orders list'
      expect_widget_presence
    end

    scenario 'empty nullable multi = false' do
      click_and_wait 'ORD-18'

      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field does not match regex'
      expect(page).not_to have_content 'Field is required'

      expect_widget_presence
    end

    scenario 'empty nullable multi = true' do
      click_and_wait 'ORD-19'

      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field does not match regex'
      expect(page).not_to have_content 'Field is required'

      expect_widget_presence
    end

    scenario 'filled required multi = false' do
      click_and_wait 'ORD-20'

      set_select_table_option 'Some name'

      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field does not match regex'
      expect(page).not_to have_content 'Field is required'

      expect_widget_presence
    end

    scenario 'filled required multi = true' do
      click_and_wait 'ORD-21'

      set_select_table_option 'Some name'
      set_select_table_option 'Other name'

      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field does not match regex'
      expect(page).not_to have_content 'Field is required'

      expect_widget_presence
    end
  end

  describe 'will not be submitted if empty required' do
    before(:each) do
      click_on 'Orders'
      expect(page).to have_content 'Orders list'
      expect_widget_presence
    end

    scenario 'multi = false' do
      click_and_wait 'ORD-20'

      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).to have_content 'Field is required'

      expect_widget_presence
    end

    scenario 'multi = true' do
      click_and_wait 'ORD-21'

      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).to have_content 'Field is required'

      expect_widget_presence
    end
  end
end
