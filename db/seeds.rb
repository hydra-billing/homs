def seed
  add_admin
  add_initial_order_types
  add_initial_orders
end

def add_admin
  User.connection.schema_cache.clear!
  User.reset_column_information

  existing_admin = User.find_by(email: 'user@example.com')

  unless existing_admin.present?
    User.create!(
      email: 'user@example.com',
      password: 'changeme',
      name: 'John',
      last_name: 'Doe',
      role: :admin,
      company: 'Example Corporation',
      department: 'Administrators',
      api_token: 'RENEWMEPLEASE'
    )
  end
end

def add_initial_order_types
  [
"common: &common
  label: ''
  type: string

order_type:
  code: vacation_request
  name: Vacation Request
  fields:
    employeeFirstName:
      <<: *common
      label: First Name
    employeeLastName:
      <<: *common
      label: Last Name
    employeeEmail:
      <<: *common
      label: E-mail
    beginDate:
      <<: *common
      label: Begin Date
      type: datetime
    endDate:
      <<: *common
      label: End Date
      type: datetime
    motivationText:
      <<: *common
      label: Motivation Text
    resolution:
      <<: *common
      label: Resolution
    resolutionText:
      <<: *common
      label: Resolution Text
    adjustResult:
      <<: *common
      label: Adjust Result",
"common: &common
  label: ''
  type: string

order_type:
  code: support_request
  name: Support Request
  fields:
    requesterName:
      <<: *common
      label: Requester Name
    requesterPhone:
      <<: *common
      label: Requester Phone
    subject:
      <<: *common
      label: Subject
    description:
      <<: *common
      label: Description
    resolution:
      <<: *common
      label: Resolution
    resolutionText:
      <<: *common
      label: Resolution Text",
"common: &common
  label: ''
  type: string

order_type:
  code: pizza_order
  name: Pizza Order
  fields:
    customerName:
      <<: *common
      label: Customer Name
    customerPhone:
      <<: *common
      label: Customer Phone
    pizzaType:
      <<: *common
      label: Pizza Type
    orderStatus:
      <<: *common
      label: Order Status
    ingredientCheese:
      <<: *common
      type: boolean
      label: Cheese Ingredient
    ingredientSalami:
      <<: *common
      type: boolean
      label: Salami Ingredient
    ingredientPepper:
      <<: *common
      type: boolean
      label: Pepper Ingredient
    ingredientMushrooms:
      <<: *common
      type: boolean
      label: Mushrooms Ingredient
    ingredientVegetables:
      <<: *common
      type: boolean
      label: Vegetables Ingredient
    ingredientOlives:
      <<: *common
      type: boolean
      label: Olives Ingredient
    pizzaPrice:
      <<: *common
      type: number
      label: Pizza Price"].each do |order_type_file|
    order_type_code = YAML.load(order_type_file).fetch('order_type').fetch('code')
    existing_order_type = OrderType.find_by(code: order_type_code)
    unless existing_order_type.present?
      OrderType.create!(
          file: order_type_file,
          active: true
      )
    end
  end
end

def add_initial_orders
  # create sequence for order
  unless Sequence.find_by(name: Sequence.model_sequence_name(Order))
    OrderSequenceService.new.create
  end

  # vacation request order
  order = Order.new(order_type_id: OrderType.find_by(code: 'vacation_request').id)

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
  order = Order.new(order_type_id: OrderType.find_by(code: 'support_request').id)

  order.data = {
    requesterName:  'Peter Park',
    requesterPhone: '12345678900',
    subject:        'The printer does not work',
    description:    "I don't know what happened, but the printer in the kitchen doesn't work. Help, please..."
  }
  order.save

  # pizza order
  order = Order.new(order_type_id: OrderType.find_by(code: 'pizza_order').id)

  order.data = {
    customerName:  'John Smith',
    customerPhone: '19876543211',
    pizzaType:     'Margherita'
  }
  order.save
end

seed
