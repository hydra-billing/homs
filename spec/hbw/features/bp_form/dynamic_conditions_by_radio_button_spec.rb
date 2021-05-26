feature 'Control fields with dynamic conditions by radio button', js: true do
  before(:each) do
    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-37')
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_and_wait 'ORD-37'

    expect(page).to have_selector "[name='controlRadioButton']", visible: false
  end

  scenario 'should hide all fields' do
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
    expect(page).to have_content 'Dependent radio button'

    click_on_radio_button_value('controlRadioButton', 'Hide fields')

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
    expect(page).not_to have_content 'Dependent radio button'
  end

  scenario 'should disable all fields' do
    expect(page.find('.dependent-select')).not_to       have_selector '.react-select--is-disabled'
    expect(page.find('.dependent-select-table')).not_to have_selector '.disabled'

    expect(is_element('dependentCheckbox', true)).to     be false
    expect(is_element('dependentUploadedFile', true)).to be false

    expect(readonly?('dependentString')).to        be false
    expect(readonly?('dependentText')).to          be false
    expect(readonly?('stringInDependentGroup')).to be false

    expect(find_by_name('dependentDatetime').disabled?).to be false

    expect(radio_button_disabled?('dependentRadioButton')).to be false

    click_on_radio_button_value('controlRadioButton', 'Disable fields')

    expect(page.find('.dependent-select')).to       have_selector '.react-select--is-disabled'
    expect(page.find('.dependent-select-table')).to have_selector '.disabled'

    expect(is_element('dependentCheckbox', true)).to     be true
    expect(is_element('dependentUploadedFile', true)).to be true

    expect(readonly?('dependentString')).to        be true
    expect(readonly?('dependentText')).to          be true
    expect(readonly?('stringInDependentGroup')).to be true

    expect(find_by_name('dependentDatetime').disabled?).to be true

    expect(radio_button_disabled?('dependentRadioButton')).to be true
  end
end
