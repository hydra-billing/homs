module Imprint
  module Services
    class OrderPrintingService
      include ::Validations
      extend Imprint::Mixin

      inject['imprint_adapter']

      schema do
        optional(:state).maybe(:int?, lteq?: 2, gteq?: 0)
        optional(:order_type_id).maybe(:int?)
        optional(:archived).maybe(:bool?)
        optional(:created_at_from).maybe(:date_time?)
        optional(:created_at_to).maybe(:date_time?)
        optional(:filter).maybe(:str?)
        optional(:user_id).maybe(:array?)

        rule(filter_only: [:filter, :user_id]) do |filter, user_id|
          filter.filled? > user_id.filled?
        end
      end

      class OrderMultipleTypesException < Exception
      end

      def process_print_task(current_user, params)
        orders_or_error = filter_and_prepare(current_user, params)

        if orders_or_error.has_key?(:error)
          orders_or_error
        else
          response = imprint_adapter.print_multiple_files(orders_or_error[:print_form_code],
                                                          orders_or_error[:orders])
          if response.body.has_key?('task_id')
            {success: I18n.t('orders.print_tasks.started', print_task_id: response.body['task_id'])}
          elsif response.body.has_key?('errors')
            {error: response.body['errors'].to_s}
          else
            {error: I18n.t('orders.print_tasks.errors.internal_error')}
          end
        end
      end

      def build_filter(current_user, params)
        ListOrdersFilter.new(current_user, prepare_filter_params(current_user, params))
      end

      private

      def filter_and_prepare(current_user, params)
        begin
          serialize_orders(check_same_type(filter_orders(current_user, params)))
        rescue OrderMultipleTypesException
          {error: I18n.t('orders.print_tasks.errors.multiple_types')}
        end
      end

      def serialize_orders(orders)
        {
            orders: orders.map { |order| order.attributes },
            print_form_code: orders.first.try(:order_type_print_form_code)
        }
      end

      def filter_orders(current_user, params)
        build_filter(current_user, params).list_orders
      end

      def check_same_type(orders)
        if orders.map(&:order_type_id).uniq.length > 1
          raise OrderMultipleTypesException
        end

        orders
      end

      def prepare_filter_params(current_user, parameters)
        result = validate(parameters.to_unsafe_hash)

        if result.success?
          result_data = result.to_h.with_indifferent_access

          user_ids = result_data[:filter] ? result_data[:user_id] : [current_user.id, 'empty']

          result_data.reverse_merge(
              user_id: user_ids,
              archived: false,
              state: nil)
        end
      end
    end
  end
end
