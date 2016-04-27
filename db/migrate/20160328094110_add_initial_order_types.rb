class AddInitialOrderTypes < ActiveRecord::Migration
  def change
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
      OrderType.create!(
          file: order_type_file,
          active: true)
    end
  end
end
