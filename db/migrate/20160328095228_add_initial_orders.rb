class AddInitialOrders < ActiveRecord::Migration
  def change
    # create sequence for order
    unless Sequence.find_by(name: Sequence.model_sequence_name(Order))
      OrderSequenceService.new.create
    end

    # vacation request order
    order = Order.new(
        order_type_id: OrderType.find_by(code: 'vacation_request').id
    )
    order.data = {
        employeeFirstName: 'James',
        employeeLastName:  'Carter',
        employeeEmail:     'james@example.com',
        beginDate:         (Time.zone.now + 3.months).iso8601,
        endDate:           (Time.zone.now + 3.months + 1.day).iso8601,
        motivationText:    'I had a lot of work last 7 years'
    }
    order.save

    # support request order
    order = Order.new(
        order_type_id: OrderType.find_by(code: 'support_request').id
    )
    order.data = {
        requesterName:  'Peter Park',
        requesterPhone: '12345678900',
        subject:        'Printer does not work',
        description:    'I don\'t know what happened but printer in kitchen does not work. Help, please...'
    }
    order.save

    # pizza order
    order = Order.new(
        order_type_id: OrderType.find_by(code: 'pizza_order').id
    )
    order.data = {
        customerName:  'John Smith',
        customerPhone: '19876543211',
        pizzaType:     'Margherita'
    }
    order.save
  end
end
