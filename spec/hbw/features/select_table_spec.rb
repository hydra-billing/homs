feature 'Select table', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/select_table_mock.yml')

    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type:) # ORD-1
    FactoryBot.create(:order, order_type:) # ORD-2
    FactoryBot.create(:order, order_type:) # ORD-3
    FactoryBot.create(:order, order_type:) # ORD-4
    FactoryBot.create(:order, order_type:) # ORD-5
  end

  scenario 'rendered with static variants' do
    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-1'

    expect(page).to have_content 'ORD-1'

    expect(page).to have_content 'Name'
    expect(page).to have_content 'Code'
    expect(page).to have_content 'Arbitrary number'

    expect(page).to have_content 'My favourite region name'
    expect(page).to have_content 'My favourite region code'
    expect(page).to have_content '235,234,521.00'

    expect(page).to have_content 'My favourite region name2'
    expect(page).to have_content 'My favourite region code2'
    expect(page).to have_content '3,252,349,284.00'

    expect(page).to have_content 'Custom cancel button name'
    expect(page).to have_content 'Custom submit button name'

    expect_widget_presence
  end

  describe 'will be submitted if' do
    before(:each) do
      click_on 'Orders'
      expect(page).to have_content 'Orders list'
      expect_widget_presence
    end

    scenario 'empty bp variable, nullable, multi = false' do
      click_and_wait 'ORD-2'

      real_initial_table_values = {
        table_options:    options_in_table_with_label('emptyDefaultParam'),
        selected_options: selected_options_in_table_with_label('emptyDefaultParam')
      }

      expected_initial_table_values = {
        table_options:    ['-', 'Some name'].sort,
        selected_options: []
      }

      expect(real_initial_table_values).to eq(expected_initial_table_values)
      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field does not match regex'
      expect(page).not_to have_content 'Field is required'

      expect_widget_presence
    end

    scenario 'empty bp variable, nullable, multi = true' do
      click_and_wait 'ORD-3'

      real_initial_table_values = {
        table_options:    options_in_table_with_label('emptyDefaultParam'),
        selected_options: selected_options_in_table_with_label('emptyDefaultParam')
      }

      expected_initial_table_values = {
        table_options:    ['Some name', 'Other name'].sort,
        selected_options: []
      }

      expect(real_initial_table_values).to eq(expected_initial_table_values)
      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field does not match regex'
      expect(page).not_to have_content 'Field is required'

      expect_widget_presence
    end

    scenario 'not empty bp variable, nullable, multi = false' do
      click_and_wait 'ORD-2'

      real_initial_table_values = {
        table_options:    options_in_table_with_label('notEmptyDefaultParam'),
        selected_options: selected_options_in_table_with_label('notEmptyDefaultParam')
      }

      expected_initial_table_values = {
        table_options:    ['-', 'Other name', 'Some name'].sort,
        selected_options: ['Other name']
      }

      expect(real_initial_table_values).to eq(expected_initial_table_values)
      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field does not match regex'
      expect(page).not_to have_content 'Field is required'

      expect_widget_presence
    end

    scenario 'not empty bp variable, nullable, multi = true' do
      click_and_wait 'ORD-3'

      real_initial_table_values = {
        table_options:    options_in_table_with_label('notEmptyDefaultParam'),
        selected_options: selected_options_in_table_with_label('notEmptyDefaultParam')
      }

      expected_initial_table_values = {
        table_options:    ['Some name', 'Other name'].sort,
        selected_options: ['Other name']
      }

      expect(real_initial_table_values).to eq(expected_initial_table_values)
      expect(page).to have_selector "button[type='submit']"

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field does not match regex'
      expect(page).not_to have_content 'Field is required'

      expect_widget_presence
    end

    scenario 'filled required multi = false' do
      click_and_wait 'ORD-4'
      real_initial_table_values = {
        table_options:,
        selected_options:
      }

      expected_initial_table_values = {
        table_options:    ['Some name', 'Other name'].sort,
        selected_options: ['Other name']
      }

      expect(real_initial_table_values).to eq(expected_initial_table_values)
      expect(selected_options).to eq(['Other name'])

      click_on_select_table_option 'Some name'
      expect(selected_options).to eq(['Some name'])

      expect(page).to have_selector "button[type='submit']"
      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field does not match regex'
      expect(page).not_to have_content 'Field is required'

      expect_widget_presence
    end

    scenario 'filled required multi = true' do
      click_and_wait 'ORD-5'

      real_initial_table_values = {
        table_options:,
        selected_options:
      }

      expected_initial_table_values = {
        table_options:    ['Some name', 'Other name'].sort,
        selected_options: ['Some name']
      }

      expect(real_initial_table_values).to eq(expected_initial_table_values)

      click_on_select_table_option 'Other name'
      expect(selected_options).to eq(['Some name', 'Other name'].sort)

      expect(page).to have_selector "button[type='submit']"
      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field does not match regex'
      expect(page).not_to have_content 'Field is required'

      expect_widget_presence
    end
  end

  describe 'will not be submitted if' do
    before(:each) do
      click_on 'Orders'
      expect(page).to have_content 'Orders list'
      expect_widget_presence
    end

    scenario 'filled required multi = true' do
      click_and_wait 'ORD-5'

      expect(selected_options_in_table_with_label('Options')).to eq(['Some name'])
      expect(page).not_to have_content 'Field is required'

      click_on_select_table_option 'Some name'

      expect(selected_options_in_table_with_label('Options')).to eq([])
      expect(page).to have_content 'Field is required'

      expect(page).to have_selector "button[type='submit']"
      click_and_wait 'Submit'

      expect(page).to have_content 'Field is required'

      expect_widget_presence
    end
  end
end
