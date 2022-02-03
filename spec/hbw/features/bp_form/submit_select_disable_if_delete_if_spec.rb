feature 'Control fields on form', js: true do
  before(:each) do
    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-39')

    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait 'ORD-39'

    expect(page).to have_content 'ORD-39'
  end

  scenario 'disable_if for submit_select' do
    in_group_with_label('submit_select to be disabled group') do |group|
      group.find_button('button1', disabled: true)
      group.find_button('button2', disabled: true)
    end

    in_group_with_label('submit_select to be enabled group') do |group|
      group.find_button('button1', disabled: false)
      group.find_button('button2', disabled: false)
    end

    in_group_with_label('submit_select buttons to be disabled group') do |group|
      group.find_button('disabledButton', disabled: true)
      group.find_button('enabledButton',  disabled: false)
    end
  end

  scenario 'delete_if for submit_select' do
    in_group_with_label('submit_select to be hidden group') do |group|
      expect(group).not_to have_content 'button1'
      expect(group).not_to have_content 'button2'
    end

    in_group_with_label('submit_select to be visible group') do |group|
      expect(group).to have_content 'button1'
      expect(group).to have_content 'button2'
    end

    in_group_with_label('submit_select buttons to be hidden group') do |group|
      expect(group).not_to have_content 'hiddenButton'
      expect(group).to have_content 'visibleButton'
    end
  end
end
