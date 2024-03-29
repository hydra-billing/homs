feature 'Check description on top of filelist', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/bp_form/description_file_list_mock.yml')

    order_type = FactoryBot.create(:order_type, :support_request)
    FactoryBot.create(:order, order_type:) # ORD-1
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_and_wait 'ORD-1'
  end

  scenario 'should contain a top filelist descriptions' do
    parent_top = page.find('.filelist-top')
    expect(page).to have_selector "[name='topDescriptionFileList']", visible: false
    expect(find_by_dt('description-top', parent_top).text).to eq 'Top description test'
  end
end
