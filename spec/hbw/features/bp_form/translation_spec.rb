feature 'BP form with existing russian translation', js: true do
  before(:each) do
    user = FactoryBot.create(:user)
    order_type = FactoryBot.create(:order_type, :new_customer)
    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-32')

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    set_locale(locale)
  end

  after(:each) do
    reset_locale
  end

  describe 'with current lang = ru' do
    let(:locale) { :ru }

    scenario 'should be translated to russian' do
      click_and_wait 'ORD-32'

      expect(page).to     have_content 'ORD-32'
      expect(page).to     have_content 'Заполните адрес абонента'
      expect(page).not_to have_content 'Enter customer\'s address'

      form = find_bp_form_with_name('Заполните адрес абонента')

      expect(form).to     have_content 'Город'
      expect(form).to     have_content 'Улица'
      expect(form).not_to have_content 'City'
      expect(form).not_to have_content 'Street'

      expect_widget_presence
    end
  end

  describe 'with current lang = en' do
    let(:locale) { :en }

    scenario 'should not be translated to russian' do
      click_and_wait 'ORD-32'

      expect(page).to     have_content 'ORD-32'
      expect(page).to     have_content 'Enter customer\'s address'
      expect(page).not_to have_content 'Заполните адрес абонента'

      form = find_bp_form_with_name('Enter customer\'s address')

      expect(form).to     have_content 'City'
      expect(form).to     have_content 'Street'
      expect(form).not_to have_content 'Город'
      expect(form).not_to have_content 'Улица'

      expect_widget_presence
    end
  end
end
