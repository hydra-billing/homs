module Imprint
  class PrintsController < ApplicationController
    include ::Validations
    extend Imprint::Mixin

    inject['imprint_adapter', 'services.order_printing_service']

    schema do
      required(:order_code).filled(:str?)
    end

    def print
      result = validate(params.to_unsafe_hash)

      if result.success?
        order = Order.find_by_code(params[:order_code])

        response = imprint_adapter.print_single_file(order.order_type_print_form_code,
                                                     order.attributes,
                                                     params[:convert_to_pdf])

        if response.nil?
          flash[:error] = I18n.t('orders.print_tasks.errors.internal_error')
          redirect_to request.referer
        else
          send_data(response.body, type:            response.headers[:content_type],
                                   disposition:     response.headers[:content_disposition],
                                   security_policy: response.headers[:content_security_policy])
        end
      else
        flash[:error] = result.messages.map { |k, v| '%s %s.' % [k, v.join] }.join("\n")

        redirect_to request.referer
      end
    end

    def print_task
      render json: order_printing_service.process_print_task(current_user, params).to_a
    end
  end
end
