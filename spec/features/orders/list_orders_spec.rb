feature 'List orders', js: true do
  let!(:user)                   { FactoryGirl.create(:user) }
  let!(:john)                   { FactoryGirl.create(:user, :john) }
  let!(:vacation_request_type)  { FactoryGirl.create(:order_type, :vacation_request, name: 'Vacation request') }
  let!(:support_request_type)   { FactoryGirl.create(:order_type, :support_request, name: 'Support request') }
  let!(:vacation_request_order) { FactoryGirl.create(:order, :order_vacation_request) }
  let!(:support_request_order)  { FactoryGirl.create(:order, :order_support_request, order_type: support_request_type) }
  let!(:problem_descriptions)   { 'Problem description' }
  let!(:contract_number)        { 111 }

  before(:each) do
    signin(user.email, user.password)

    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence
  end

  scenario 'with correct filter defaults' do
    # "Filter orders" tab is active by default
    expect(active_tab 'Filter orders').not_to be_nil

    # "Order type" select
    expect(label('order_type_id')).to                eq('Order type')
    expect(placeholder('order_type_id')).to          eq('Order type')
    expect(select2_default_text('order_type_id')).to eq('Order type')
    expect(select_options('order_type_id')).to       eq(['Empty order type',
                                                         'Support request',
                                                         'Vacation request'])

    # "Order status" select
    expect(label('state')).to                eq('Order status')
    expect(placeholder('state')).to          eq('Order status')
    expect(select2_default_text('state')).to eq('Order status')
    expect(select_options('state')).to       eq(['To execute',
                                                 'In progress',
                                                 'Done'])

    # "Archived" select
    expect(label('archived')).to          eq('Archived')
    expect(placeholder('archived')).to    eq('Archived')
    expect(select2_text('archived')).to   eq('No')
    expect(select_options('archived')).to eq(%w(Yes No))

    # "User name" multiple select
    expect(label('user_id')).to                   eq('User name')
    expect(placeholder('user_id[]')).to           eq('User name')
    expect(select2_multiple_text('user_id[]')).to eq([user.full_name, 'Empty'])
    expect(select_options('user_id[]')).to        eq([user.full_name, 'Empty'])
    # enter 2 symbols in lookup and find users
    expect(success_select_search('user_id[]', 'Jo')).to eq([john.full_name, user.full_name])

    # Calendar "From"
    expect(label('created_at_from')).to          eq('From')
    expect(calendar_value('created_at_from')).to eq(in_current_locale((DateTime.now - 1.day).beginning_of_day))

    # Calendar "To"
    expect(label('created_at_to')).to          eq('To')
    expect(calendar_value('created_at_to')).to eq(in_current_locale((DateTime.now).end_of_day))

    # Estimated execution date "From"
    expect(label('estimated_exec_date_from')).to          eq('From')
    expect(calendar_value('estimated_exec_date_from')).to be_nil

    # Estimated execution date "To"
    expect(label('estimated_exec_date_to')).to          eq('To')
    expect(calendar_value('estimated_exec_date_to')).to be_nil
  end

  scenario 'with changing filter parameters' do
    current_orders_list = [[], ['ORD-1', 'Empty order type', 'In progress',
                                in_current_locale(vacation_request_order.created_at), '', 'ext_code', '',
                                in_current_locale(vacation_request_order.estimated_exec_date)]]
    # "Order type"
    change_select2_value('order_type_id', 'Vacation request')
    search_button.click
    expect(empty_order_list).not_to eq(nil)

    change_select2_value('order_type_id', 'Empty order type')
    search_button.click
    expect(orders_list).to eq(current_orders_list)

    # "Archived"
    change_select2_value('archived', 'Yes')
    search_button.click
    expect(empty_order_list).not_to eq(nil)

    change_select2_value('archived', 'No')
    search_button.click
    expect(orders_list).to eq(current_orders_list)

    # "Order status"
    change_select2_value('state', 'To execute')
    search_button.click
    expect(empty_order_list).not_to eq(nil)

    change_select2_value('state', 'In progress')
    search_button.click
    expect(orders_list).to eq(current_orders_list)

    # Calendar "From"
    calendar_date_button('created_at_from').click
    calendar_clear_button('created_at_from').click
    expect(calendar_value('created_at_from')).to eq(nil)

    search_button.click
    expect(orders_list).to eq(current_orders_list)

    set_datetime_picker_date('created_at_from', in_current_locale(vacation_request_order.created_at + 1.minute))
    search_button.click
    expect(empty_order_list).not_to eq(nil)

    calendar_date_button('created_at_from').click
    calendar_clear_button('created_at_from').click
    search_button.click
    expect(orders_list).to eq(current_orders_list)

    # Calendar "To"
    set_datetime_picker_date('created_at_to', in_current_locale(vacation_request_order.created_at - 1.minute))
    search_button.click
    expect(empty_order_list).not_to eq(nil)

    set_datetime_picker_date('created_at_to', in_current_locale(vacation_request_order.created_at + 1.minute))
    search_button.click
    expect(orders_list).to eq(current_orders_list)

    # Estimated execution date "From"
    set_datetime_picker_date('estimated_exec_date_from', in_current_locale(vacation_request_order.estimated_exec_date + 1.minute))
    search_button.click
    expect(empty_order_list).not_to be_nil

    calendar_date_button('estimated_exec_date_from').click
    calendar_clear_button('estimated_exec_date_from').click
    search_button.click
    expect(orders_list).to eq(current_orders_list)

    # Estimated execution date "To"
    set_datetime_picker_date('estimated_exec_date_to', in_current_locale(vacation_request_order.estimated_exec_date - 1.minute))
    search_button.click
    expect(empty_order_list).not_to be_nil

    set_datetime_picker_date('estimated_exec_date_to', in_current_locale(vacation_request_order.estimated_exec_date + 1.minute))
    search_button.click
    expect(orders_list).to eq(current_orders_list)

    # "User name"
    select2_cross('user_id[]', 'Empty').click
    search_button.click
    expect(empty_order_list).not_to eq(nil)
  end

  scenario 'with filter by custom fields' do
    result_orders_list = [[], ['ORD-2', 'Support request', 'In progress',
                               in_current_locale(support_request_order.created_at), '', 'support_ext_code', '',
                               in_current_locale(support_request_order.estimated_exec_date)]]

    # default state
    expect(label('custom_field_select')).to                eq('Add filter by attribute')
    expect(placeholder('custom_field_select')).to          eq('Select order attribute')
    expect(select2_default_text('custom_field_select')).to eq('Select order attribute')
    expect(select_options('custom_field_select')).to       eq([])

    # activate custom field filter selector
    change_select2_value('order_type_id', 'Support request')
    wait_for_ajax

    expect(select2_text('custom_field_select')).to   eq('Creation date')
    expect(select_options('custom_field_select')).to eq(['Creation date',
                                                         'Problem description',
                                                         'Callback',
                                                         'Contract number'])

    # custom field filter with type 'string'
    change_select2_value('custom_field_select', 'Problem description')
    expect(select2_text('custom_field_select')).to eq('Problem description')
    add_custom_field_filter
    expect(label('problemDescription')).to eq('Problem description')

    fill_in('custom_fields[problemDescription]', with: problem_descriptions.reverse)
    search_button.click
    expect(empty_order_list).not_to eq(nil)

    fill_in('custom_fields[problemDescription]', with: problem_descriptions)
    search_button.click
    expect(orders_list).to eq(result_orders_list)

    # custom field filter with type 'boolean'
    change_select2_value('custom_field_select', 'Callback')
    expect(select2_text('custom_field_select')).to eq('Callback')
    add_custom_field_filter
    expect(label('callBack')).to eq('Callback')

    search_button.click
    expect(empty_order_list).not_to be_nil

    click_checkbox_div('callBack')
    search_button.click
    expect(orders_list).to eq(result_orders_list)

    # custom field filter with type 'number'
    change_select2_value('custom_field_select', 'Contract number')
    expect(select2_text('custom_field_select')).to eq('Contract number')
    add_custom_field_filter
    expect(label('contractNumber')).to eq('Contract number')

    fill_in('custom_fields[contractNumber]', with: contract_number + 1)
    search_button.click
    expect(empty_order_list).not_to be_nil

    fill_in('custom_fields[contractNumber]', with: contract_number)
    search_button.click
    expect(orders_list).to eq(result_orders_list)

    # custom field filter with type 'datetime'
    change_select2_value('custom_field_select', 'Creation date')
    expect(select2_text('custom_field_select')).to eq('Creation date')
    add_custom_field_filter
    expect(label('creationDate')).to eq('Creation date')

    set_datetime_picker_date('custom_fields[creationDate][from]',
                             in_current_locale(DateTime.iso8601(support_request_order.data['creationDate']) + 1.day))
    search_button.click
    expect(empty_order_list).not_to be_nil

    set_datetime_picker_date('custom_fields[creationDate][from]',
                             in_current_locale(DateTime.iso8601(support_request_order.data['creationDate']) - 1.day))
    search_button.click
    expect(orders_list).to eq(result_orders_list)

    # order type removing should clear all custom field filters
    select2_clear_cross('order_type_id').click

    expect(placeholder('custom_field_select')).to          eq('Select order attribute')
    expect(select2_default_text('custom_field_select')).to eq('Select order attribute')
    expect(select_options('custom_field_select')).to       eq([])
    expect(page).not_to have_selector('[name="custom_fields[problemDescription]"]')
    expect(page).not_to have_selector('[name="custom_fields[callBack]"]')
    expect(page).not_to have_selector('[name="custom_fields[contractNumber]"]')
    expect(page).not_to have_selector('[name="custom_fields[creationDate]"]')
  end

  scenario 'with correct search by code' do
    tab('Search for an order').click
    input_by_placeholder('Order code').set(vacation_request_order.code)

    search_button_by_action('/orders/search_by/code').click
    expect(header.text).to eq('ORD-1 Empty order type')
  end

  scenario 'with correct search by ext code' do
    tab('Search for an order').click
    input_by_placeholder('Order external code').set(vacation_request_order.ext_code)

    search_button_by_action('/orders/search_by/ext_code').click
    expect(header.text).to eq('ORD-1 Empty order type')
  end
end
