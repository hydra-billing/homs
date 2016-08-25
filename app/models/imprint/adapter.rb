module Imprint
  class Adapter
    extend Imprint::Mixin

    inject['imprint_api']

    def print_single_file(template_code, template_substitution, convert_to_pdf = false)
      imprint_api.post('print', template:       template_code,
                                data:           template_substitution,
                                convert_to_pdf: convert_to_pdf)
    end

    def print_multiple_files(template_code, template_substitutions, convert_to_pdf = false)
      imprint_api.post('print_tasks', template:       template_code,
                                      data:           template_substitutions,
                                      convert_to_pdf: convert_to_pdf)
    end
  end
end
