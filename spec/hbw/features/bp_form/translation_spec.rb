feature 'BP form with existing russian translation', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/bp_form/translation_mock.yml')

    user = FactoryBot.create(:user)
    order_type = FactoryBot.create(:order_type, :new_customer)
    FactoryBot.create(:order, order_type:)

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
      click_and_wait 'ORD-1'

      expect(page).to     have_content 'Тестирование переводов'
      expect(page).to     have_content 'ORD-1'
      expect(page).to     have_content 'Форма для тестирования переводов'

      expect(page).to     have_content 'Поле select'
      expect(page).to     have_content 'Другое поле select'
      expect(page).to     have_content 'Описание поля select'
      expect(page).to     have_content 'Поле string'
      expect(page).to     have_content 'Описание поля string'
      expect(page).to     have_content 'Поле string c regexp валидацией'
      expect(page).to     have_content 'Поле static с подстановкой ORD-1'
      expect(page).to     have_content 'Поле select_table'
      expect(page).to     have_content 'Описание поля select_table'
      expect(page).to     have_content 'Колонка 1'
      expect(page).to     have_content 'Поле text'
      expect(page).to     have_content 'Описание поля text'
      expect(page).to     have_content 'Поле datetime'
      expect(page).to     have_content 'Описание поля datetime'
      expect(page).to     have_content 'Группа'
      expect(page).to     have_content 'Поле file_upload'
      expect(page).to     have_content 'Описание поля file_upload'
      expect(page).to     have_content 'Прикрепите файлы'
      expect(page).to     have_content 'Перенесите файл сюда'
      expect(page).to     have_content 'Поле file_list'
      expect(page).to     have_content 'Описание поля file_list'
      expect(page).to     have_content 'Поле checkbox'
      expect(page).to     have_content 'Описание поля checkbox'
      expect(page).to     have_content 'Кнопка 1'
      expect(page).to     have_content 'Кнопка 2'

      fill_in 'stringRegexpField', with: '123dfgdfg'

      expect(page).to have_content 'Поле не соответствует regexp'

      expect(r_select_options('selectField')).to eq ['Опция1']
      expect(r_select_options('anotherSelectField')).to eq ['Первая опция']

      expect(page).not_to     have_content 'Test translations'
      expect(page).not_to     have_content 'Form for testing of field translations'

      expect(page).not_to     have_content 'Select field'
      expect(page).not_to     have_content 'String field'
      expect(page).not_to     have_content 'Static field with substitution ORD-1'
      expect(page).not_to     have_content 'Select table field'
      expect(page).not_to     have_content 'Text field'
      expect(page).not_to     have_content 'Datetime field'
      expect(page).not_to     have_content 'Group'
      expect(page).not_to     have_content 'File upload field'
      expect(page).not_to     have_content 'Put file here'
      expect(page).not_to     have_content 'Upload files'
      expect(page).not_to     have_content 'Checkbox field'
      expect(page).not_to     have_content 'Button 1'
      expect(page).not_to     have_content 'Button 2'

      expect_widget_presence
    end
  end

  describe 'with current lang = en' do
    let(:locale) { :en }

    scenario 'should have text from form config' do
      click_and_wait 'ORD-1'

      expect(page).to     have_content 'Test translations'
      expect(page).to     have_content 'ORD-1'
      expect(page).to     have_content 'Form for testing of field translations'

      expect(page).to     have_content 'Select field'
      expect(page).to     have_content 'String field'
      expect(page).to     have_content 'String Regexp field'
      expect(page).to     have_content 'Static field with substitution ORD-1'
      expect(page).to     have_content 'Select table field'
      expect(page).to     have_content 'Text field'
      expect(page).to     have_content 'Datetime field'
      expect(page).to     have_content 'Group'
      expect(page).to     have_content 'File upload field'
      expect(page).to     have_content 'Put file here'
      expect(page).to     have_content 'Upload files'
      expect(page).to     have_content 'Checkbox field'
      expect(page).to     have_content 'submitSelectButton1'
      expect(page).to     have_content 'submitSelectButton2'

      fill_in 'stringRegexpField', with: '123dfgdfg'

      expect(page).to have_content 'Field does not match regexp'

      expect(r_select_options('selectField')).to eq ['Option1']
      expect(r_select_options('anotherSelectField')).to eq ['First option']

      expect(page).not_to have_content 'Тестирование переводов'
      expect(page).not_to have_content 'Форма для тестирования переводов'

      expect(page).not_to have_content 'Поле select'
      expect(page).not_to have_content 'Поле string'
      expect(page).not_to have_content 'Поле static с подстановкой ORD-1'
      expect(page).not_to have_content 'Поле select_table'
      expect(page).not_to have_content 'Поле text'
      expect(page).not_to have_content 'Поле datetime'
      expect(page).not_to have_content 'Группа'
      expect(page).not_to have_content 'Поле file_upload'
      expect(page).not_to have_content 'Перенесите файл сюда'
      expect(page).not_to have_content 'Прикрепите файлы'
      expect(page).not_to have_content 'Поле file_list'
      expect(page).not_to have_content 'Поле checkbox'
      expect(page).not_to have_content 'Кнопка 1'
      expect(page).not_to have_content 'Кнопка 2'

      expect_widget_presence
    end
  end
end
