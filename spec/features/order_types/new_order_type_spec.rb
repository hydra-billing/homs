feature 'Create new order type', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/features/order_types/new_order_type_mock.yml')

    user = FactoryBot.create(:user, :admin)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_on 'Order types'
    expect(page).to have_content 'Order types'
    expect_widget_presence
  end

  scenario 'success' do
    attach_file('order_type_file',
                fixtures_path('order_types/support_request.yml'),
                visible: false)

    expect(page).to have_css '.file-caption-name', text: 'support_request.yml'

    click_on 'Upload'
    expect(page).to have_content 'Support Request'
    expect(page).to have_css     '.growl-notice', text: 'Order type successfully loaded'
    expect(page).to have_css     '.btn-danger',   text: 'Activate'
    expect(page).to have_css     '.btn-primary',  text: 'Dismiss'
    expect_widget_presence
    expect(OrderType.find_by_code('support_request').active).to be_falsey
    expect(page).to have_content(YAML.load(fixture('order_types/support_request.yml'))['order_type']['code'])

    click_on 'Activate'
    expect(page).to have_css     '.growl-notice', text: 'Order type activated'
    expect(page).to have_content 'Order types'
    expect(page).to have_content 'Support Request'
    expect_widget_presence
    expect(OrderType.find_by_code('support_request').active).to be_truthy

    delete_order_type('Support Request')
    expect(page).to have_css '.modal-body', text: 'Are you sure you want to delete the order type «Support Request»? Existing orders won\'t be affected.'

    click_on 'Cancel'
    expect(page).to have_no_css '.confirmation_dialog'

    delete_order_type('Support Request')
    page.find('.close').click
    expect(page).to have_no_css '.confirmation_dialog'

    delete_order_type('Support Request')
    click_on 'Yes, delete'

    expect(page).to have_css        '.growl-notice', text: 'Order type deleted'
    expect(page).to have_no_content 'Support Request'
    expect(OrderType.find_by_code('support_request').active).to be_falsey
  end

  scenario 'dismissed' do
    attach_file('order_type_file',
                fixtures_path('order_types/support_request.yml'),
                visible: false)

    expect(page).to have_css '.file-caption-name', text: 'support_request.yml'

    click_on 'Upload'
    expect(page).to have_content 'Support Request'
    expect(page).to have_css     '.btn-danger',  text: 'Activate'
    expect(page).to have_css     '.btn-primary', text: 'Dismiss'
    expect_widget_presence
    expect(OrderType.find_by_code('support_request').active).to be_falsey
    expect(page).to have_content(YAML.load(fixture('order_types/support_request.yml'))['order_type']['code'])

    click_on 'Dismiss'
    expect(page).to have_no_content 'Support Request'
    expect_widget_presence
    expect(OrderType.find_by_code('support_request').present?).to be_falsey
  end

  scenario 'rejected' do
    attach_file('order_type_file',
                fixtures_path('order_types/support_request.yml'),
                visible: false)

    expect(page).to have_css '.file-caption-name', text: 'support_request.yml'

    click_on 'Remove'
    expect(page).to have_no_css '.file-caption-name', text: 'support_request.yml'
    expect(page).to have_no_css '.fileinput-upload-button'
    expect(page).to have_no_css '.fileinput-remove-button'
  end

  scenario 'failed with invalid field type' do
    attach_file('order_type_file',
                fixtures_path('order_types/invalid_field_request.yml'),
                visible: false)

    expect(page).to have_css '.file-caption-name', text: 'invalid_field_request.yml'

    click_on 'Upload'
    expect(page).to have_css        '.growl-message', text: "Loaded YAML file contents [\"creationDate: Unknown type 'undefined'\"]"
    expect(page).to have_no_css     '.btn-danger',    text: 'Activate'
    expect(page).to have_no_css     '.btn-primary',   text: 'Dismiss'
    expect(page).to have_no_content 'Support Request'
    expect_widget_presence
    expect(OrderType.find_by_code('support_request').present?).to be_falsey
  end

  scenario 'failed with invalid yml' do
    attach_file('order_type_file',
                fixtures_path('order_types/invalid_yml_request.yml'),
                visible: false)

    expect(page).to have_css '.file-caption-name', text: 'invalid_yml_request.yml'

    click_on 'Upload'
    expect(page).to have_css        '.growl-message', text: "Loaded YAML file contents [\"Missing attribute 'order_type'\"]"
    expect(page).to have_no_css     '.btn-danger',    text: 'Activate'
    expect(page).to have_no_css     '.btn-primary',   text: 'Dismiss'
    expect(page).to have_no_content 'Support Request'
    expect_widget_presence
    expect(OrderType.find_by_code('support_request').present?).to be_falsey
  end

  scenario 'access denied' do
    logout

    visit admin_order_types_path

    expect(page).to have_content 'Sign in'
  end
end
