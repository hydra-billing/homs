require 'dry-container'
require 'dry-auto_inject'

module Imprint
  class Adapter
    include Imprint::Wrapper.inject[:imprint_api]

    def print_single_file(template_code, template_substitution, convert_to_pdf = false)
      imprint_api.post('print', {template: template_code}.merge(data: template_substitution)
                                                         .merge(convert_to_pdf: convert_to_pdf))
    end

    def print_multiple_files(template_code, template_substitution, convert_to_pdf = false)
      imprint_api.post('print_task', {template: template_code}.merge(data: template_substitution)
                                                              .merge(convert_to_pdf: convert_to_pdf))
    end
  end
end
