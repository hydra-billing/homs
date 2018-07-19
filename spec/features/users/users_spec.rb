feature 'User is', js: true do
  let!(:admin)         { FactoryBot.create(:user, :admin) }
  let!(:john)          { FactoryBot.create(:user, :john) }
  let!(:blocked_admin) { FactoryBot.create(:user, :blocked_admin) }

  scenario 'created without validation errors' do
    signin(admin.email, admin.password)

    click_on 'Users'
    expect(page).to have_content 'User list'
    expect_widget_presence

    users = [
        ['Blocked Doe', 'b.j.doe@example.com', 'Admin', 'Marketing', 'LLC Tools', ''],
        ['John Doe', 'j.doe@example.com', 'User', 'Marketing', 'LLC Tools', ''],
        ['Christopher Johnson', 'c.johnson@example.com', 'Admin', 'Administrators', 'LLC Tools', '']
    ]
    expect(table_lines).to eq users

    button.click
    expect(header3.text).to                        eq 'Add a user'
    expect(label_node('user_name').text).to        eq 'First name'
    expect(label_node('user_middle_name').text).to eq 'Middle name'
    expect(label_node('user_last_name').text).to   eq 'Last name'
    expect(label_node('user_email').text).to       eq 'Email'
    expect(label_node('user_role').text).to        eq 'Role'
    expect(label_node('user_company').text).to     eq 'Company'
    expect(label_node('user_department').text).to  eq 'Department'
    expect(label_node('user_password').text).to    eq 'Password'
    expect(label_node('user_password_confirmation').text).to eq 'Password confirmation'

    button.click
    expect(validation_errors_container.find('.alert').text).to eq '6 prohibited this user from being saved:'
    expect(validation_errors_container.all('li').map(&:text)).to eq [
                                                                        'Email is not specified',
                                                                        'Password is not specified',
                                                                        'First name is not specified',
                                                                        'Last name is not specified',
                                                                        'Company is not specified',
                                                                        'Department is not specified'
                                                                    ]
    expect(is_input_in_error?('user_name')).to       be true
    expect(input_error_text('user_name')).to         eq 'is not specified'

    expect(is_input_in_error?('user_last_name')).to  be true
    expect(input_error_text('user_last_name')).to    eq 'is not specified'

    expect(is_input_in_error?('user_email')).to      be true
    expect(input_error_text('user_email')).to        eq 'is not specified'

    expect(is_input_in_error?('user_company')).to    be true
    expect(input_error_text('user_company')).to      eq 'is not specified'

    expect(is_input_in_error?('user_department')).to be true
    expect(input_error_text('user_department')).to   eq 'is not specified'

    expect(is_input_in_error?('user_password')).to   be true
    expect(input_error_text('user_password')).to     eq 'is not specified'

    input_by_label('user_email').set('testtest')
    button.click
    expect(validation_errors_container.find('.alert').text).to eq '6 prohibited this user from being saved:'
    expect(input_error_text('user_email')).to                  eq 'is invalid'

    input_by_label('user_password').set('q')
    button.click
    expect(validation_errors_container.find('.alert').text).to eq '7 prohibited this user from being saved:'
    expect(input_error_text('user_password')).to               eq 'is too short'
    expect(input_error_text('user_password_confirmation')).to  eq 'is not completed'

    input_by_label('user_name').set                  'Mark'
    input_by_label('user_middle_name').set           'Jay'
    input_by_label('user_last_name').set             'Jenkins'
    input_by_label('user_email').set                 'm.jenkins@example.com'
    input_by_label('user_company').set               'LLC Tools'
    input_by_label('user_department').set            'Administrators'
    input_by_label('user_password').set              'qwe123123123'
    input_by_label('user_password_confirmation').set 'qwe123123123'
    select_by_label('user_role').find('option[value="admin"]').select_option
    button.click

    users = [
        ['Blocked Doe', 'b.j.doe@example.com', 'Admin', 'Marketing', 'LLC Tools', ''],
        ['John Doe', 'j.doe@example.com', 'User', 'Marketing', 'LLC Tools', ''],
        ['Mark Jenkins', 'm.jenkins@example.com', 'Admin', 'Administrators', 'LLC Tools', ''],
        ['Christopher Johnson', 'c.johnson@example.com', 'Admin', 'Administrators', 'LLC Tools', '']
    ]
    expect(table_lines).to eq users

    mark = User.find_by_name('Mark')
    expect(mark.middle_name).to eq 'Jay'
    expect(mark.last_name).to   eq 'Jenkins'
    expect(mark.email).to       eq 'm.jenkins@example.com'
    expect(mark.role).to        eq 'admin'
    expect(mark.company).to     eq 'LLC Tools'
    expect(mark.department).to  eq 'Administrators'
  end

  scenario 'able to control API token' do
    signin(admin.email, admin.password)

    click_on 'Users'
    expect(page).to have_content 'User list'
    expect_widget_presence

    expect(admin.api_token).to be_nil

    link_by_href("/users/#{admin.id}").click
    expect(header.text).to                         eq('User profile')
    expect(user_edit(admin).text).to               eq('Edit')
    expect(user_generate_api_token(admin).text).to eq('Generate API token')
    expect(user_data).to eq [
                                'Full name: Christopher Johnson',
                                'Email: c.johnson@example.com',
                                'Role: Admin',
                                'Company: LLC Tools',
                                'Department: Administrators',
                                'API token:'
                            ]

    user_generate_api_token(admin).click
    expect(user_generate_api_token(admin).text).to eq 'Renew API token'
    expect(is_button_red?("/users/#{admin.id}/generate_api_token")).to be true

    admin.reload
    expect(user_clear_api_token(admin).text).to eq 'Clear API token'
    expect(is_button_red?("/users/#{admin.id}/clear_api_token")).to be true
    expect(admin.api_token).not_to be_nil
    expect(user_data).to eq [
                                'Full name: Christopher Johnson',
                                'Email: c.johnson@example.com',
                                'Role: Admin',
                                'Company: LLC Tools',
                                'Department: Administrators',
                                "API token: #{admin.api_token}"
                            ]

    user_clear_api_token(admin).click
    expect(active_modal_dialog_body.text).to    eq 'Existing API token is about to be cleared. Are you sure?'
    expect(active_modal_dialog_cancel.text).to  eq 'Cancel'
    expect(active_modal_dialog_proceed.text).to eq 'Yes, clear'

    active_modal_dialog_cancel.click
    expect(active_modal_dialogs.length).to eq 0

    user_clear_api_token(admin).click
    expect(active_modal_dialog_body.text).to    eq 'Existing API token is about to be cleared. Are you sure?'
    expect(active_modal_dialog_cancel.text).to  eq 'Cancel'
    expect(active_modal_dialog_proceed.text).to eq 'Yes, clear'

    active_modal_dialog_proceed.click
    expect(active_modal_dialogs.length).to eq 0
    expect(user_data).to eq [
                                'Full name: Christopher Johnson',
                                'Email: c.johnson@example.com',
                                'Role: Admin',
                                'Company: LLC Tools',
                                'Department: Administrators',
                                'API token:'
                            ]
    expect(user_edit(admin).text).to               eq 'Edit'
    expect(user_generate_api_token(admin).text).to eq 'Generate API token'

    admin.reload
    expect(admin.api_token).to be_nil

    user_generate_api_token(admin).click
    expect(user_generate_api_token(admin).text).to eq('Renew API token')
    expect(is_button_red?("/users/#{admin.id}/generate_api_token")).to be true

    admin.reload
    expect(user_data).to eq [
                                'Full name: Christopher Johnson',
                                'Email: c.johnson@example.com',
                                'Role: Admin',
                                'Company: LLC Tools',
                                'Department: Administrators',
                                "API token: #{admin.api_token}"
                            ]

    user_generate_api_token(admin).click
    expect(active_modal_dialog_body.text).to    eq 'New API token will replace the existing one. Are you sure?'
    expect(active_modal_dialog_cancel.text).to  eq 'Cancel'
    expect(active_modal_dialog_proceed.text).to eq 'Yes, renew'

    active_modal_dialog_cancel.click
    expect(active_modal_dialogs.length).to eq 0

    user_generate_api_token(admin).click
    expect(active_modal_dialog_body.text).to    eq 'New API token will replace the existing one. Are you sure?'
    expect(active_modal_dialog_cancel.text).to  eq 'Cancel'
    expect(active_modal_dialog_proceed.text).to eq 'Yes, renew'

    active_modal_dialog_proceed.click
    expect(active_modal_dialogs.length).to eq 0

    previous_api_token = admin.api_token
    admin.reload
    expect(admin.api_token).not_to eq previous_api_token
    expect(user_data).to eq [
                                'Full name: Christopher Johnson',
                                'Email: c.johnson@example.com',
                                'Role: Admin',
                                'Company: LLC Tools',
                                'Department: Administrators',
                                "API token: #{admin.api_token}"
                            ]
  end

  scenario 'editable' do
    signin(admin.email, admin.password)

    click_on 'Users'
    expect(page).to have_content 'User list'
    expect_widget_presence

    link_by_href("/users/#{john.id}").click
    expect_widget_presence

    expect(header.text).to                        eq 'User profile'
    expect(user_edit(john).text).to               eq 'Edit'
    expect(user_generate_api_token(john).text).to eq 'Generate API token'

    expect(user_data).to eq([
                                'Full name: John Doe',
                                'Email: j.doe@example.com',
                                'Role: User',
                                'Company: LLC Tools',
                                'Department: Marketing',
                                'API token:'
                            ])

    user_edit(john).click
    expect(label_node('user_name').text).to        eq 'First name'
    expect(label_node('user_middle_name').text).to eq 'Middle name'
    expect(label_node('user_last_name').text).to   eq 'Last name'
    expect(label_node('user_email').text).to       eq 'Email'
    expect(label_node('user_role').text).to        eq 'Role'
    expect(label_node('user_company').text).to     eq 'Company'
    expect(label_node('user_department').text).to  eq 'Department'
    expect(label_node('user_password').text).to    eq 'Password'
    expect(label_node('user_password_confirmation').text).to eq 'Password confirmation'

    input_by_label('user_name').set                  'Mark'
    input_by_label('user_middle_name').set           'Jay'
    input_by_label('user_last_name').set             'Jenkins'
    input_by_label('user_email').set                 'm.jenkins@example.com'
    input_by_label('user_company').set               'LLC Tools'
    input_by_label('user_department').set            'Administrators'
    input_by_label('user_password').set              'qwe123123123'
    input_by_label('user_password_confirmation').set 'qwe123123123'
    select_by_label('user_role').find('option[value="admin"]').select_option

    button.click

    users = [
        ['Blocked Doe', 'b.j.doe@example.com', 'Admin', 'Marketing', 'LLC Tools', ''],
        ['Mark Jenkins', 'm.jenkins@example.com', 'Admin', 'Administrators', 'LLC Tools', ''],
        ['Christopher Johnson', 'c.johnson@example.com', 'Admin', 'Administrators', 'LLC Tools', '']
    ]
    expect(table_lines).to eq users

    previous_password = john.encrypted_password
    john.reload
    expect(john.name).to        eq 'Mark'
    expect(john.middle_name).to eq 'Jay'
    expect(john.last_name).to   eq 'Jenkins'
    expect(john.email).to       eq 'm.jenkins@example.com'
    expect(john.role).to        eq 'admin'
    expect(john.company).to     eq 'LLC Tools'
    expect(john.department).to  eq 'Administrators'
    expect(john.encrypted_password).not_to eq previous_password
  end

  scenario 'inaccessible for ordinary user' do
    signin(john.email, john.password)

    expect(page).not_to have_content 'User list'
  end

  scenario 'inaccessible for blocked user' do
    signin(blocked_admin.email, blocked_admin.password)

    expect(page).not_to have_content 'Orders list'
  end
end
