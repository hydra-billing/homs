module Features
  module FilesHelper
    def attach_files(input, file_paths)
      file_input = page.find_field(input, type: :file, visible: :hidden)

      file_input.attach_file(file_paths.map { |path| Rails.root.join(path) })
    end

    def file_upload_error_message(field_name)
      page.find('.hbw-file-upload-label', exact_text: field_name).sibling('.alert-danger').text
    end

    def expect_error_in_file_upload(field_name)
      page.find('.hbw-file-upload-label', exact_text: field_name).assert_sibling('.alert-danger')
      page.find('.hbw-file-upload-label', exact_text: field_name).assert_sibling('.has-error')
    end

    def expect_no_error_in_file_upload(field_name)
      page.find('.hbw-file-upload-label', exact_text: field_name).assert_no_sibling('.alert-danger')
      page.find('.hbw-file-upload-label', exact_text: field_name).assert_no_sibling('.has-error')
    end
  end
end
