module Features
  module FilesHelper
    def attach_files(input, file_paths)
      file_input = page.find_field(input, type: :file)

      file_input.attach_file(file_paths.map { |path| Rails.root.join(path) })
    end
  end
end
