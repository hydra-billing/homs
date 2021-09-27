feature 'Control fields with dynamic conditions by select table', js: true do
  let(:neutral_option_cell) { find(:xpath, "//*[text() = 'Neutral option']") }
  let(:disable_fields_cell) { find(:xpath, "//*[text() = 'Disable fields']") }
  let(:hide_fields_cell)    { find(:xpath, "//*[text() = 'Hide fields']") }

  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/bp_form/dynamic_conditions_by_select_table_mock.yml')

    order_type = FactoryBot.create(:order_type, :new_customer)
    FactoryBot.create(:order, order_type: order_type) # ORD-1

    user = FactoryBot.create(:user)
    signin(user.email, user.password)

    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'
  end

  scenario 'should do nothing when neutral field is selected' do
    click_and_wait 'ORD-1'

    expect(page).to have_content 'Control select table'
    expect(page).to have_content 'Dependent static'
    expect(page).to have_content 'Dependent select'
    expect(page).to have_content 'Dependent checkbox'
    expect(page).to have_content 'Dependent select_table'
    expect(page).to have_content 'Dependent file_list'
    expect(page).to have_content 'Dependent group'
    expect(page).to have_content 'Dependent datetime'
    expect(page).to have_content 'Dependent string'
    expect(page).to have_content 'Dependent text'
    expect(page).to have_content 'Dependent file_upload'
    expect(page).to have_content 'Dependent radio_button'

    in_group_with_label('Dependent submit_select group') do |group|
      group.find_button('Button 1', disabled: false)
      group.find_button('Button 2', disabled: false)
    end
    in_group_with_label('Dependent submit_select buttons group') do |group|
      group.find_button('Neutral button',        disabled: false)
      group.find_button('Button to be disabled', disabled: false)
      group.find_button('Button to be hidden',   disabled: false)
    end

    neutral_option_cell.click

    expect(page).to have_content 'Control select table'
    expect(page).to have_content 'Dependent static'
    expect(page).to have_content 'Dependent select'
    expect(page).to have_content 'Dependent checkbox'
    expect(page).to have_content 'Dependent select_table'
    expect(page).to have_content 'Dependent file_list'
    expect(page).to have_content 'Dependent group'
    expect(page).to have_content 'Dependent datetime'
    expect(page).to have_content 'Dependent string'
    expect(page).to have_content 'Dependent text'
    expect(page).to have_content 'Dependent file_upload'
    expect(page).to have_content 'Dependent radio_button'

    expect(page.find('.dependent-select')).not_to       have_selector '.react-select--is-disabled'
    expect(page.find('.dependent-select-table')).not_to have_selector '.disabled'
    expect(is_element('dependentCheckbox', true)).to     be false
    expect(is_element('dependentUploadedFile', true)).to be false
    expect(readonly?('dependentString')).to        be false
    expect(readonly?('dependentText')).to          be false
    expect(readonly?('stringInDependentGroup')).to be false
    expect(find_by_name('dependentDatetime-visible-input').disabled?).to be false
    expect(radio_button_disabled?('dependentRadioButton')).to be false

    in_group_with_label('Dependent submit_select group') do |group|
      group.find_button('Button 1', disabled: false)
      group.find_button('Button 2', disabled: false)
    end
    in_group_with_label('Dependent submit_select buttons group') do |group|
      group.find_button('Neutral button',        disabled: false)
      group.find_button('Button to be disabled', disabled: false)
      group.find_button('Button to be hidden',   disabled: false)
    end
  end

  scenario 'should hide dependent fields' do
    click_and_wait 'ORD-1'

    expect(page).to have_content 'Control select table'
    expect(page).to have_content 'Dependent static'
    expect(page).to have_content 'Dependent select'
    expect(page).to have_content 'Dependent checkbox'
    expect(page).to have_content 'Dependent select_table'
    expect(page).to have_content 'Dependent file_list'
    expect(page).to have_content 'Dependent group'
    expect(page).to have_content 'Dependent datetime'
    expect(page).to have_content 'Dependent string'
    expect(page).to have_content 'Dependent text'
    expect(page).to have_content 'Dependent file_upload'
    expect(page).to have_content 'Dependent radio_button'

    in_group_with_label('Dependent submit_select group') do |group|
      expect(group).to have_content 'Button 1'
      expect(group).to have_content 'Button 2'
    end
    in_group_with_label('Dependent submit_select buttons group') do |group|
      expect(group).to have_content 'Neutral button'
      expect(group).to have_content 'Button to be disabled'
      expect(group).to have_content 'Button to be hidden'
    end

    hide_fields_cell.click

    expect(page).to have_content 'Control select table'
    expect(page).not_to have_content 'Dependent static'
    expect(page).not_to have_content 'Dependent select'
    expect(page).not_to have_content 'Dependent checkbox'
    expect(page).not_to have_content 'Dependent select_table'
    expect(page).not_to have_content 'Dependent file_list'
    expect(page).not_to have_content 'Dependent group'
    expect(page).not_to have_content 'Dependent datetime'
    expect(page).not_to have_content 'Dependent string'
    expect(page).not_to have_content 'Dependent text'
    expect(page).not_to have_content 'Dependent file_upload'
    expect(page).not_to have_content 'Dependent radio_button'

    in_group_with_label('Dependent submit_select group') do |group|
      expect(group).not_to have_content 'Button 1'
      expect(group).not_to have_content 'Button 2'
    end
    in_group_with_label('Dependent submit_select buttons group') do |group|
      expect(group).to     have_content 'Neutral button'
      expect(group).to     have_content 'Button to be disabled'
      expect(group).not_to have_content 'Button to be hidden'
    end
  end

  scenario 'should disable dependent fields' do
    click_and_wait 'ORD-1'

    expect(page).to have_content 'Control select table'

    expect(page.find('.dependent-select')).not_to       have_selector '.react-select--is-disabled'
    expect(page.find('.dependent-select-table')).not_to have_selector '.disabled'
    expect(is_element('dependentCheckbox', true)).to     be false
    expect(is_element('dependentUploadedFile', true)).to be false
    expect(readonly?('dependentString')).to        be false
    expect(readonly?('dependentText')).to          be false
    expect(readonly?('stringInDependentGroup')).to be false
    expect(find_by_name('dependentDatetime-visible-input').disabled?).to be false
    expect(radio_button_disabled?('dependentRadioButton')).to be false

    in_group_with_label('Dependent submit_select group') do |group|
      group.find_button('Button 1', disabled: false)
      group.find_button('Button 2', disabled: false)
    end
    in_group_with_label('Dependent submit_select buttons group') do |group|
      group.find_button('Neutral button',        disabled: false)
      group.find_button('Button to be disabled', disabled: false)
      group.find_button('Button to be hidden',   disabled: false)
    end

    disable_fields_cell.click

    expect(page.find('.dependent-select')).to       have_selector '.react-select--is-disabled'
    expect(page.find('.dependent-select-table')).to have_selector '.disabled'
    expect(is_element('dependentCheckbox', true)).to     be true
    expect(is_element('dependentUploadedFile', true)).to be true
    expect(readonly?('dependentString')).to        be true
    expect(readonly?('dependentText')).to          be true
    expect(readonly?('stringInDependentGroup')).to be true
    expect(find_by_name('dependentDatetime-visible-input').disabled?).to be true
    expect(radio_button_disabled?('dependentRadioButton')).to be true

    in_group_with_label('Dependent submit_select group') do |group|
      group.find_button('Button 1', disabled: true)
      group.find_button('Button 2', disabled: true)
    end
    in_group_with_label('Dependent submit_select buttons group') do |group|
      group.find_button('Neutral button',        disabled: false)
      group.find_button('Button to be disabled', disabled: true)
      group.find_button('Button to be hidden',   disabled: false)
    end
  end
end
