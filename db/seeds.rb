def seed
  if ENV['SEED_DB'] == 'true'
    add_admin
    add_initial_order_types
    add_initial_orders
  else
    puts 'db was not seeded'
  end
end

def add_admin
  User.connection.schema_cache.clear!
  User.reset_column_information
  admin_email = ENV['ADMIN_EMAIL'] || 'user@example.com'
  admin_password = ENV['ADMIN_PASSWORD'] || 'changeme'
  admin_token = ENV['ADMIN_API_TOKEN'] || 'RENEWMEPLEASE'

  existing_admin = User.find_by(email: admin_email)

  unless existing_admin.present?
    User.create!(
      email: admin_email,
      password: admin_password,
      name: 'John',
      last_name: 'Doe',
      role: :admin,
      company: 'Example Corporation',
      department: 'Administrators',
      api_token: admin_token
    )
  end
end

def add_initial_order_types
  [
"
order_type:
  code: relocate_customer
  name: Relocate Customer
  fields:
    customerCity:
      type: string
      label: Customer City
    customerStreet:
      type: string
      label: Customer Street
    customerHouse:
      type: string
      label: Customer House
    customerEntrance:
      type: string
      label: Customer House
    addressIsAvailable:
      type: boolean
      label: Customer address is available

    changePlan:
      type: boolean
      label: Change Plan

    planId:
      type: number
      label: Customer Plan
    planComment:
      type: string
      label: Comment to plan

    customerName:
      type: string
      label: Customer Name
    customerSurname:
      type: string
      label: Customer Surname
    customerPhone:
      type: string
      label: Customer Phone
    customerEmail:
      type: string
      label: Customer Email
    installDate:
      type: datetime
      label: Install Date",
"
order_type:
  code: new_customer
  name: New Customer
  fields:
    customerCity:
      type: string
      label: Customer City
    customerStreet:
      type: string
      label: Customer Street
    customerHouse:
      type: string
      label: Customer House
    customerEntrance:
      type: string
      label: Customer House
    addressIsAvailable:
      type: boolean
      label: Customer address is available
    planId:
      type: number
      label: Customer Plan
    planComment:
      type: string
      label: Comment to plan
    customerName:
      type: string
      label: Customer Name
    customerSurname:
      type: string
      label: Customer Surname
    customerPhone:
      type: string
      label: Customer Phone
    customerEmail:
      type: string
      label: Customer Email
    installDate:
      type: datetime
      label: Install Date
    fromFriends:
      type: boolean
      label: Friends
    fromTV:
      type: boolean
      label: TV
    fromFacebookAds:
      type: boolean
      label: Facebook Ads
    fromOther:
      type: string
      label: Other
    fileList:
      type: json
      label: Attached files
    uploadedFile:
      type: json
      label: Attach file",

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

  unless Order.exists?(order_type_id: OrderType.find_by(code: 'new_customer'))
    order = Order.new(order_type_id: OrderType.find_by(code: 'new_customer').id)

    order.data = {
      customerCity: 'Omsk'
    }
    order.save
  end

  unless Order.exists?(order_type_id: OrderType.find_by(code: 'relocate_customer'))
    order = Order.new(order_type_id: OrderType.find_by(code: 'relocate_customer').id)

    order.data = {
      customerCity: 'Moscow'
    }
    order.save
  end

  unless Order.exists?(order_type_id: OrderType.find_by(code: 'pizza_order'))
    order = Order.new(order_type_id: OrderType.find_by(code: 'pizza_order').id)

    order.data = {
      customerName:  'John Smith',
      customerPhone: '19876543211',
      pizzaType:     'Margherita'
    }
    order.save
  end
end

seed
