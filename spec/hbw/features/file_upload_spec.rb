feature 'File upload field with', js: true do
  before(:each) do
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    order_type = FactoryBot.create(:order_type, :support_request)

    FactoryBot.create(:order, order_type: order_type).update(code: 'ORD-15')

    click_on 'Orders'
    expect(page).to have_content 'Orders list'
    expect_widget_presence

    click_and_wait('ORD-15')

    expect(page).to have_content 'ORD-15'
  end

  scenario 'multuple = true should allow to attach several files' do
    expect(page).to have_field('homsOrderDataUploadedFile', type: :file, visible: :hidden)
    expect(page.find_field('homsOrderDataUploadedFile', type: :file, visible: :hidden).multiple?).to be true
  end

  scenario 'should render drop aria' do
    expect(page).to have_selector '.hbw-file-upload'
    expect(page.first('.hbw-file-upload')).to have_content 'Drag and drop files to attach, or browse'
  end

  scenario 'file list field missing renders warning' do
    expect(page).to have_field('homsOrderDataUploadedFile', type: :file, visible: :hidden)
    expect(page).to have_content('To load files please add a field of file_list type with the name homsOrderDataFileList')
    expect_widget_presence
  end

  describe 'attached files' do
    let(:files_to_attach) do
      [
        'fixtures/attached_files/logo.svg',
        'fixtures/attached_files/file.txt',
        'fixtures/attached_files/file_with_long_name.pdf'
      ]
    end

    before(:each) do
      attach_files('homsOrderDataUploadedFile', files_to_attach)
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

      page.find("img[alt='logo.svg']").hover
      click_on_icon 'far.fa-times-circle'

      expect(preview_row).to have_no_text 'logo.svg'
      expect(preview_row).to have_no_css  "img[alt='logo.svg']"
    end
  end

  scenario 'should attach to different file_uploads' do
    attach_files(
      'homsOrderDataUploadedFile',
      [
        'fixtures/attached_files/logo.svg',
        'fixtures/attached_files/file_with_long_name.pdf'
      ]
    )

    file_second_input = page.find_field('homsOrderDataUploadedFileSecond', type: :file, visible: :hidden)
    file_second_input.attach_file(Rails.root.join('fixtures/attached_files/file.txt'))

    preview_rows = page.all('.files-preview-row')
    expect(preview_rows.length).to eq(2)
    expect(preview_rows[0]).to have_content 'logo.svg'
    expect(preview_rows[0]).to have_css "img[alt='logo.svg']"
    expect(preview_rows[0]).to have_content 'file_with...me.pdf'
    expect(preview_rows[0]).to have_css "embed[type='application/pdf']"

    expect(preview_rows[1]).to have_content 'file.txt'
    expect(preview_rows[1]).to have_css "span[class='far fa-file fa-7x'"
  end

  scenario 'should append files if multiple is true' do
    attach_files(
      'homsOrderDataUploadedFile',
      [
        'fixtures/attached_files/logo.svg',
        'fixtures/attached_files/file_with_long_name.pdf'
      ]
    )

    file_input = page.find_field('homsOrderDataUploadedFile', type: :file, visible: :hidden)
    file_input.attach_file(Rails.root.join('fixtures/attached_files/file.txt'))

    preview_rows = page.all('.files-preview-row')
    expect(preview_rows[0]).to have_content 'logo.svg'
    expect(preview_rows[0]).to have_css "img[alt='logo.svg']"
    expect(preview_rows[0]).to have_content 'file_with...me.pdf'
    expect(preview_rows[0]).to have_css "embed[type='application/pdf']"
    expect(preview_rows[0]).to have_content 'file.txt'
    expect(preview_rows[0]).to have_css "span[class='far fa-file fa-7x'"
  end

  scenario 'should substitute files if multiple is false or absent' do
    file_second_input = page.find_field('homsOrderDataUploadedFileSecond', type: :file, visible: :hidden)
    file_second_input.attach_file(Rails.root.join('fixtures/attached_files/logo.svg'))
    file_second_input.attach_file(Rails.root.join('fixtures/attached_files/file.txt'))

    preview_rows = page.all('.files-preview-row')
    expect(preview_rows[0]).not_to have_content 'logo.svg'
    expect(preview_rows[0]).not_to have_css "img[alt='logo.svg']"

    expect(preview_rows[0]).to have_content 'file.txt'
    expect(preview_rows[0]).to have_css "span[class='far fa-file fa-7x'"
  end
end
