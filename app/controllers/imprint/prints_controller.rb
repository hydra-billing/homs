module Imprint
  class PrintsController < ApplicationController
    def print
      order = Order.find_by_code(params[:order_code])

      response = Imprint::Wrapper.container[:imprint_adapter].print_single_file(order.order_type_print_form_code,
                                                                                order.attributes,
                                                                                params[:convert_to_pdf])

      send_data(response.body, type: response.headers[:content_type],
                               disposition: response.headers[:content_disposition],
                               security_policy: response.headers[:content_security_policy])
    end
  end
end
