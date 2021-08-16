feature 'File upload field', js: true do
  before(:each) do
    set_camunda_api_mock_file('spec/hbw/features/file_upload_mock.yml')

    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type: order_type) # ORD-1
    FactoryBot.create(:order, order_type: order_type) # ORD-2

    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence
  end

  describe 'with properly configured fields' do
    before(:each) do
      click_and_wait('ORD-1')
      expect(page).to have_content 'ORD-1'
    end

    scenario 'with multuple = true should allow to attach several files' do
      expect(page).to have_field('multipleFileUpload', type: :file, visible: :hidden)
      expect(page.find_field('multipleFileUpload', type: :file, visible: :hidden).multiple?).to be true
    end

    scenario 'should render drop aria' do
      expect(page).to have_selector '.hbw-file-upload'
      expect(page.first('.hbw-file-upload')).to have_content 'Drag and drop files to attach, or browse'
    end

    scenario 'should allow to attach files to different file_uploads' do
      attach_files(
        'multipleFileUpload',
        [
          'fixtures/attached_files/logo.svg',
          'fixtures/attached_files/file_with_long_name.pdf'
        ]
      )

      second_file_input = page.find_field('singleFileUpload', type: :file, visible: :hidden)
      second_file_input.attach_file(Rails.root.join('fixtures/attached_files/file.txt'))

      preview_rows = page.all('.files-preview-row')

      expect(preview_rows.length).to eq(2)
      expect(preview_rows[0]).to have_content 'logo.svg'
      expect(preview_rows[0]).to have_css     "img[alt='logo.svg']"
      expect(preview_rows[0]).to have_content 'file_with...me.pdf'
      expect(preview_rows[0]).to have_css     "embed[type='application/pdf']"

      expect(preview_rows[1]).to have_content 'file.txt'
      expect(preview_rows[1]).to have_css     "span[class='far fa-file fa-7x'"
    end

    scenario 'should append files if multiple is true' do
      attach_files(
        'multipleFileUpload',
        [
          'fixtures/attached_files/logo.svg',
          'fixtures/attached_files/file_with_long_name.pdf'
        ]
      )

      file_input = page.find_field('multipleFileUpload', type: :file, visible: :hidden)
      file_input.attach_file(Rails.root.join('fixtures/attached_files/file.txt'))

      preview_rows = page.all('.files-preview-row')
      expect(preview_rows[0]).to have_content 'logo.svg'
      expect(preview_rows[0]).to have_css     "img[alt='logo.svg']"
      expect(preview_rows[0]).to have_content 'file_with...me.pdf'
      expect(preview_rows[0]).to have_css     "embed[type='application/pdf']"
      expect(preview_rows[0]).to have_content 'file.txt'
      expect(preview_rows[0]).to have_css     "span[class='far fa-file fa-7x'"
    end

    scenario 'should hide input area if the only possible file has been attached' do
      expect(page).to have_content 'Drag single file, or browse'

      single_file_input = page.find_field('singleFileUpload', type: :file, visible: :hidden)
      single_file_input.attach_file(Rails.root.join('fixtures/attached_files/logo.svg'))

      preview_row = page.find('.files-preview-row')

      expect(preview_row).to have_content 'logo.svg'
      expect(preview_row).to have_css     "img[alt='logo.svg']"
      expect(page).not_to    have_content 'Drag single file, or browse'
    end

    scenario 'should submit several upload file fields' do
      multiple_file_input_in_group = page.find_field('multipleFileUpload', type: :file, visible: :hidden)
      multiple_file_input_in_group.attach_file(Rails.root.join('fixtures/attached_files/logo.svg'))
      multiple_file_input_in_group.attach_file(Rails.root.join('fixtures/attached_files/file_with_long_name.pdf'))

      single_file_input = page.find_field('singleFileUpload', type: :file, visible: :hidden)
      single_file_input.attach_file(Rails.root.join('fixtures/attached_files/file.txt'))

      param_absent_file_upload = page.find_field('paramAbsentFileUpload', type: :file, visible: :hidden)
      param_absent_file_upload.attach_file(Rails.root.join('fixtures/attached_files/file2.txt'))

      preview_rows = page.all('.files-preview-row')

      expect(preview_rows.length).to eq(3)
      expect(preview_rows[0]).to have_content 'logo.svg'
      expect(preview_rows[0]).to have_css     "img[alt='logo.svg']"
      expect(preview_rows[0]).to have_content 'file_with...me.pdf'
      expect(preview_rows[0]).to have_css     "embed[type='application/pdf']"

      expect(preview_rows[1]).to have_content 'file2.txt'
      expect(preview_rows[1]).to have_css     "span[class='far fa-file fa-7x'"

      expect(preview_rows[2]).to have_content 'file.txt'
      expect(preview_rows[2]).to have_css     "span[class='far fa-file fa-7x'"

      click_and_wait 'Submit'
    end

    scenario 'should render files in file_list variable' do
      input_with_files = find(:xpath, "//input[@name='FL_SingleFileUpload']", visible: false)
      input_without_files1 = find(:xpath, "//input[@name='FL_MultipleFileUpload']", visible: false)
      input_without_files2 = find(:xpath, "//input[@name='FL_EmptyFileUpload']", visible: false)

      real_values = {
        input_with_files:     input_with_files.value,
        input_without_files1: input_without_files1.value,
        input_without_files2: input_without_files2.value,
        ul_with_files:        input_with_files.sibling('label').all(:xpath, './ul/li').map(&:text),
        ul_without_files1:    input_without_files1.sibling('label').all(:xpath, './ul/li').map(&:text),
        ul_without_files2:    input_without_files2.sibling('label').all(:xpath, './ul/li').map(&:text)
      }

      expected_values = {
        input_with_files:     '[{"name":"file3.txt (21.07.2021 16:57:16)","origin_name":"file3.txt","field_name":"multipleFileUpload","end_point":"http://127.0.0.1:9000","bucket":"bucket-name"},{"name":"file4.txt (21.07.2021 16:57:16)","origin_name":"file4.txt","field_name":"multipleFileUpload","end_point":"http://127.0.0.1:9000","bucket":"bucket-name"}]',
        input_without_files1: '[]',
        input_without_files2: '[]',
        ul_with_files:        ['file3.txt (21.07.2021 16:57:16) ', 'file4.txt (21.07.2021 16:57:16) '],
        ul_without_files1:    [],
        ul_without_files2:    []
      }

      expect(real_values).to eq(expected_values)
    end

    describe 'with attached files' do
      let(:files_to_attach) do
        [
          'fixtures/attached_files/logo.svg',
          'fixtures/attached_files/file.txt',
          'fixtures/attached_files/file_with_long_name.pdf'
        ]
      end

      before(:each) do
        attach_files('multipleFileUpload', files_to_attach)
      end

      scenario 'should render thumbnailed uploaded files' do
        preview_row = page.find('.files-preview-row')

        expect(preview_row).to have_content 'logo.svg'
        expect(preview_row).to have_content 'file.txt'
        expect(preview_row).to have_content 'file_with...me.pdf'

        expect(preview_row).to have_css "img[alt='logo.svg']"
        expect(preview_row).to have_css "embed[type='application/pdf']"
        expect(preview_row).to have_css "span[class='far fa-file fa-7x'"
      end

      scenario 'thumbnailed preview should allow to remove attached file' do
        preview_row = page.find('.files-preview-row')

        expect(preview_row).to have_content 'logo.svg'
        expect(preview_row).to have_css     "img[alt='logo.svg']"

        logo_svg = page.find("img[alt='logo.svg']").ancestor('.files-preview-item')
        logo_svg.hover.find('.remove-file').click

        expect(preview_row).to have_no_text 'logo.svg'
        expect(preview_row).to have_no_css  "img[alt='logo.svg']"
      end
    end
  end

  describe 'with not properly configured fields' do
    before(:each) do
      click_and_wait('ORD-2')
      expect(page).to have_content 'ORD-2'
    end

    scenario 'should render error if file_list_name parameter empty / not matched / not unique' do
      real_error_messages = {
        fieldParamEmpty:      file_upload_error_message('fieldParamEmpty'),
        fieldParamEmptyStr:   file_upload_error_message('fieldParamEmptyStr'),
        fieldParamNotMatched: file_upload_error_message('fieldParamNotMatched')
      }

      expected_error_messages = {
        fieldParamEmpty:      'The field fieldParamEmpty must have not empty "file_list_name" parameter',
        fieldParamEmptyStr:   'The field fieldParamEmptyStr must have not empty "file_list_name" parameter',
        fieldParamNotMatched: 'The form is missing a field with type "file_list" and name "FL_FieldParamNotMatched_typo"'
      }

      expect(real_error_messages).to eq(expected_error_messages)

      expect_error_in_file_upload('fieldParamEmpty')
      expect_error_in_file_upload('fieldParamEmptyStr')
      expect_error_in_file_upload('fieldParamNotMatched')

      page.find('.hbw-file-upload-label', text: 'fieldNormalConfig').assert_no_sibling('.alert-danger')
      page.find('.hbw-file-upload-label', text: 'fieldParamAbsent').assert_no_sibling('.alert-danger')

      expect_no_error_in_file_upload('fieldNormalConfig')
      expect_no_error_in_file_upload('fieldParamAbsent')
    end
  end
end
