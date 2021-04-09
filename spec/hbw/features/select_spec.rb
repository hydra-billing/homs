feature 'Check select', js: true do
  let(:placeholder) { 'placeholder' }
  let(:first_value) { 'Option 1' }

  before(:each) do
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type)
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-12')
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-17')
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-22')
  end

  describe 'rendering with options' do
    before(:each) do
      click_on 'Orders'
      expect(page).to have_content 'Orders list'
      expect_widget_presence
    end

    scenario 'nullable = true and placeholder present' do
      click_and_wait 'ORD-3'

      expect(page).to have_content 'ORD-3'
      expect_r_select_presence('homsOrderDataSelect')
      expect(r_select_placeholder('homsOrderDataSelect')).to eq placeholder
      expect_widget_presence
    end

    scenario 'nullable = false and placeholder is provided but not shown' do
      click_and_wait 'ORD-4'

      expect(page).to have_content 'ORD-4'
      expect_r_select_presence('homsOrderDataSelect')
      expect(r_select_single_value('homsOrderDataSelect')[:label]).to eq first_value
      expect_widget_presence
    end

    scenario 'nullable = true and placeholder blank' do
      click_and_wait 'ORD-5'

      expect(page).to have_content 'ORD-5'
      expect_r_select_presence('homsOrderDataSelect')
      expect(r_select_placeholder('homsOrderDataSelect', visible: false)).to eq ''
      expect_widget_presence
    end

    scenario 'nullable = false and placeholder blank' do
      click_and_wait 'ORD-6'

      expect(page).to have_content 'ORD-6'
      expect_r_select_presence('homsOrderDataSelect')
      expect(r_select_single_value('homsOrderDataSelect')[:label]).to eq first_value
      expect_widget_presence
    end

    scenario 'defining choices as arrays' do
      click_and_wait 'ORD-7'

      expect(page).to have_content 'ORD-7'
      expect_r_select_presence('homsOrderDataSelect')
      expect(r_select_single_value('homsOrderDataSelect')).to eq({label: 'Option 1', value: '112233'})

      set_r_select_option('homsOrderDataSelect', 'Option 2')

      expect(r_select_single_value('homsOrderDataSelect')).to eq({label: 'Option 2', value: '445566'})
      expect_widget_presence
    end

    scenario 'defining choices as strings' do
      click_and_wait 'ORD-8'

      expect(page).to have_content 'ORD-8'
      expect_r_select_presence('homsOrderDataSelect')
      expect(r_select_single_value('homsOrderDataSelect')).to eq({label: 'Option 1', value: 'Option 1'})

      set_r_select_option('homsOrderDataSelect', 'Option 2')

      expect(r_select_single_value('homsOrderDataSelect')).to eq({label: 'Option 2', value: 'Option 2'})
      expect_widget_presence
    end

    scenario 'field name not defined in BP variables' do
      click_and_wait 'ORD-9'

      expect(page).to have_content 'ORD-9'
      expect_r_select_presence('homsOrderNotInVBPVariables')
      expect(page).to have_content 'Field with the name homsOrderNotInVBPVariables is not defined in BP variables'
      expect_widget_presence
    end

    scenario 'BP variable value is null for required field' do
      click_and_wait 'ORD-12'

      expect(page).to have_content 'ORD-12'
      expect_r_select_presence('homsOrderDataSelect')
      expect(r_select_single_value('homsOrderDataSelect')[:label]).to eq first_value
      expect(page).to have_no_content 'Field with name homsOrderNotInVBPVariables not defined in BP variables'
      expect_widget_presence
    end

    scenario 'description placement = top' do
      click_and_wait 'ORD-3'

      expect(page).to have_content 'ORD-3'
      select_root = find_by_dt('select-homsOrderDataSelect')
      expect(find_by_dt('description-top', select_root).text).to eq 'Top description text'
      expect_widget_presence
    end

    scenario 'description placement = bottom' do
      click_and_wait 'ORD-4'

      expect(page).to have_content 'ORD-4'
      select_root = find_by_dt('select-homsOrderDataSelect')
      expect(find_by_dt('description-bottom', select_root).text).to eq 'Bottom description text'
      expect_widget_presence
    end
  end

  describe 'will be submitted with lookup mode' do
    before(:each) do
      click_on 'Orders'
      expect(page).to have_content 'Orders list'
      expect_widget_presence
    end

    scenario 'nullable = true, value is empty' do
      click_and_wait 'ORD-17'

      expect(page).to have_content 'ORD-17'
      expect_r_select_presence('homsOrderDataSelect')
      expect(r_select_placeholder('homsOrderDataSelect')).to eq placeholder

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field is required'
      expect_widget_presence
    end

    scenario 'nullable = false, value is set' do
      click_and_wait 'ORD-22'

      expect(page).to have_content 'ORD-22'
      expect_r_select_presence('homsOrderDataSelect')
      expect(r_select_placeholder('homsOrderDataSelect')).to eq placeholder

      r_select_input('homsOrderDataSelect').set('text')
      wait_for_ajax

      expect(r_select_lookup_options('homsOrderDataSelect')).to eq ['Some text']

      set_r_select_lookup_option('homsOrderDataSelect', 'Some text')

      click_and_wait 'Submit'

      expect(page).not_to have_content 'Field is required'
      expect_widget_presence
    end
  end

  describe 'will not be submitted with lookup mode' do
    before(:each) do
      click_on 'Orders'
      expect(page).to have_content 'Orders list'
      expect_widget_presence
    end

    scenario 'nullable = false, value is empty' do
      click_and_wait 'ORD-22'

      expect(page).to have_content 'ORD-22'
      expect_r_select_presence('homsOrderDataSelect')
      ensure_r_select_is_empty('homsOrderDataSelect')
      expect(r_select_placeholder('homsOrderDataSelect')).to eq placeholder

      click_and_wait 'Submit'

      expect(page).to have_content 'Field is required'
      expect_widget_presence
    end
  end
end
