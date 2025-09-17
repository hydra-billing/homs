module Imprint
  class PrintsController < ApplicationController
    include ::Validations
    extend Imprint::Mixin

    inject['imprint_adapter', 'services.order_printing_service']

    contract do
      params do
        required(:order_code).filled(:string)
      end
    end

    def print
      result = validate(params.to_unsafe_hash)

      if result.success?
        print_validated
      else
        validation_fail(result)
      end
    end

    def print_task
      render json: order_printing_service.process_print_task(current_user, params).to_a
    end

    private

    def print_validated
      order = Order.find_by_code(params[:order_code])
      response = imprint_adapter.print_single_file(order.order_type_print_form_code,
                                                   order.attributes,
                                                   convert_to_pdf: params[:convert_to_pdf])

      if response.nil?
        render_print_error
      else
        render_print_response(response)
      end
    end

    def validation_fail(result)
      flash[:error] = result.messages.map { |k, v| '%s %s.' % [k, v.join] }.join("\n")
      redirect_to request.referer
    end

    def render_print_error
      flash[:error] = I18n.t('orders.print_tasks.errors.internal_error')
      redirect_to request.referer
    end

    def render_print_response(response)
      send_data(response.body, type:            response.headers[:content_type],
                               disposition:     response.headers[:content_disposition],
                               security_policy: response.headers[:content_security_policy])
    end
  end
end
