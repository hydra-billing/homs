module Features
  module SessionsHelper
    # rubocop:disable Metrics/ParameterLists
    # rubocop:disable Metrics/MethodLength
    def sign_up_with(email, password, confirmation, name, middle_name,
                     last_name, company, department)
      visit new_user_registration_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', with: confirmation
      fill_in('First Name',  with: name)        if name
      fill_in('Middle name', with: middle_name) if middle_name
      fill_in('Last name',   with: last_name)   if last_name
      fill_in('Company',     with: company)     if company
      fill_in('Department',  with: department)  if department
      click_button 'Sign up'
    end
    # rubocop:enable Metrics/ParameterLists
    # rubocop:enable Metrics/MethodLength

    def signin(email, password)
      visit new_user_session_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

    def logout
      page.first('.navbar-right .dropdown').click
      click_on 'Sign out'
      page.has_css?('.authform', wait: 5, visible: true)
      expect(page).to have_selector('.authform')
    end
  end
end
