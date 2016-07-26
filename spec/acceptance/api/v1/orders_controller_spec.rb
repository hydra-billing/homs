require 'acceptance_helper'

describe API::V1::OrdersController, type: :request do
  resource I18n.t('doc.orders.resource') do
    include HttpAuthHelper

    let(:order_type_vac)         { OrderType.find_by(code: 'vacation_request') }
    let(:order_type_sup)         { OrderType.find_by(code: 'support_request') }
    let(:order_vacation_request) { Order.where(order_type_id: order_type_vac.id, done_at: nil).first }
    let(:user_for_order)         { FactoryGirl.create(:user) }

    before(:each) do
      disable_http_basic_authentication(API::V1::OrdersController)

      OrderSequenceService.new.destroy
      OrderSequenceService.new.create

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
      label: Adjust Result
    jsonField:
      type: json
      label: JSON Field",
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

      # vacation request order
      order = Order.new(
          order_type_id: OrderType.find_by(code: 'vacation_request').id
      )
      order.data = {
          employeeFirstName: 'James',
          employeeLastName:  'Carter',
          employeeEmail:     'james@example.com',
          beginDate:         '2016-07-15T14:45:03+00:00',
          endDate:           '2016-07-16T14:49:42+00:00',
          motivationText:    'I had a lot of work last 7 years',
          jsonField:         '{"name": "James"}'
      }
      order.save

      # support request order
      order = Order.new(
          order_type_id: OrderType.find_by(code: 'support_request').id
      )
      order.bp_id = 465358
      order.bp_state = 'in_progress'
      order.state = 'in_progress'
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
      order.bp_id = 205210
      order.bp_state = 'done'
      order.done_at = '2016-08-16T14:49:42+00:00'
      order.state = 'done'
      order.data = {
          customerName:  'John Smith',
          customerPhone: '19876543211',
          pizzaType:     'Margherita'
      }
      order.save
    end

    header 'Accept',       'application/json'
    header 'Content-Type', 'application/json'

    get '/api/orders?page_size=:page_size&page=:page' do
      parameter :page_size,
                I18n.t('doc.common.parameters.page_size'),
                {I18n.t('doc.common.parameters.default') => 25}
      parameter :page,
                I18n.t('doc.common.parameters.page'),
                {I18n.t('doc.common.parameters.default') => 1}

      example_request I18n.t('doc.common.cases.list'),
                      page_size: 2, page: 2 do
        expect(status).to eq(200)
        expect((JSON response_body)['orders'].map { |e| e['code'] }).to eq(%w(ORD-1))

        order = (JSON response_body)['orders'].first
        expect(order).to eq({
                                'id'              => Order.find_by_code(order['code']).id,
                                'code'            => 'ORD-1',
                                'ext_code'        => nil,
                                'bp_id'           => nil,
                                'bp_state'        => nil,
                                'state'           => 'to_execute',
                                'archived'        => false,
                                'data'            => {
                                    'employeeFirstName' => 'James',
                                    'employeeLastName'  => 'Carter',
                                    'employeeEmail'     => 'james@example.com',
                                    'beginDate'         => '2016-07-15T14:45:03.000+00:00',
                                    'endDate'           => '2016-07-16T14:49:42.000+00:00',
                                    'motivationText'    => 'I had a lot of work last 7 years',
                                    'resolution'        => nil,
                                    'resolutionText'    => nil,
                                    'adjustResult'      => nil,
                                    'jsonField'         => '{"name": "James"}'
                                },
                                'done_at'         => nil,
                                'order_type_code' => 'vacation_request',
                                'user_email'      => nil
                            })
      end
    end

    get '/api/orders/:code' do
      parameter :code,
                I18n.t('doc.orders.parameters.code'),
                required: true

      let(:code) { 'ORD-1' }

      example_request I18n.t('doc.common.cases.show') do
        expect(status).to eq(200)
        order = (JSON response_body)
        expect(order).to eq({
                                'order' => {
                                    'id'              => Order.find_by_code(code).id,
                                    'code'            => code,
                                    'ext_code'        => nil,
                                    'bp_id'           => nil,
                                    'bp_state'        => nil,
                                    'state'           => 'to_execute',
                                    'archived'        => false,
                                    'data'            => {
                                        'employeeFirstName' => 'James',
                                        'employeeLastName'  => 'Carter',
                                        'employeeEmail'     => 'james@example.com',
                                        'beginDate'         => '2016-07-15T14:45:03.000+00:00',
                                        'endDate'           => '2016-07-16T14:49:42.000+00:00',
                                        'motivationText'    => 'I had a lot of work last 7 years',
                                        'resolution'        => nil,
                                        'resolutionText'    => nil,
                                        'adjustResult'      => nil,
                                        'jsonField'         => '{"name": "James"}'
                                    },
                                    'done_at'         => nil,
                                    'order_type_code' => 'vacation_request',
                                    'user_email'      => nil
                                }
                            })
      end
    end

    post '/api/orders' do
      parameter :code,
                I18n.t('doc.orders.parameters.code'),
                required: true
      parameter :order_type_code,
                I18n.t('doc.orders.parameters.order_type_code'),
                scope: :order
      parameter :ext_code,
                I18n.t('doc.orders.parameters.ext_code'),
                scope: :order
      parameter :bp_id,
                I18n.t('doc.orders.parameters.bp_id'),
                scope: :order
      parameter :bp_state,
                I18n.t('doc.orders.parameters.bp_state'),
                scope: :order
      parameter :state,
                I18n.t('doc.orders.parameters.state'),
                {:scope                                         => :order,
                 I18n.t('doc.common.parameters.allowed_values') => Order.states.keys.join(', ')}
      parameter :done_at,
                I18n.t('doc.orders.parameters.done_at'),
                scope: :order
      parameter :archived,
                I18n.t('doc.orders.parameters.archived'),
                {:scope                                         => :order,
                 I18n.t('doc.common.parameters.allowed_values') => [true, false].join(', ')}
      parameter :data,
                I18n.t('doc.orders.parameters.data'),
                scope: :order

      let(:order_type_vac)  { OrderType.find_by(code: 'vacation_request') }
      let(:order_type_code) { order_type_vac.code }
      let(:ext_code)        { 'ext_code' }
      let(:bp_id)           { 'bp_id' }
      let(:bp_state)        { 'bp_state' }
      let(:state)           { 'in_progress' }
      let(:done_at)         { Time.zone.now.iso8601 }
      let(:archived)        { false }
      let(:data) do
        {
            'employeeFirstName' => 'James',
            'employeeLastName'  => 'Carter',
            'employeeEmail'     => 'james@example.com',
            'beginDate'         => '2016-07-15T14:45:03.000+00:00',
            'endDate'           => '2016-07-16T14:49:42.000+00:00',
            'motivationText'    => 'I had a lot of work last 7 years',
            'resolution'        => 'Resolution',
            'resolutionText'    => 'Resolution Text',
            'adjustResult'      => 'Adjust Result',
            'jsonField'         => '{"last_name": "Carter"}'
        }
      end

      example_request I18n.t('doc.common.cases.create') do
        expect(status).to eq(201)

        order = Order.where(order_type_id: order_type_vac.id).where('done_at IS NOT NULL').first
        expect(order.code).not_to eq(nil)
        expect(order.ext_code).to eq(ext_code)
        expect(order.bp_id).to    eq(bp_id)
        expect(order.bp_state).to eq(bp_state)
        expect(order.state).to    eq(state)
        expect(order.done_at).to  eq(done_at)
        expect(order.archived).to eq(archived)
        expect(order.data).to     eq(data)

        expect(JSON response_body).to eq({
                                             'order' => {
                                                 'id'              => order.id,
                                                 'code'            => order.code,
                                                 'ext_code'        => order.ext_code,
                                                 'bp_id'           => order.bp_id,
                                                 'bp_state'        => order.bp_state,
                                                 'state'           => order.state,
                                                 'archived'        => order.archived,
                                                 'data'            => order.data,
                                                 'done_at'         => order.done_at.iso8601,
                                                 'order_type_code' => order.order_type.code,
                                                 'user_email'      => nil
                                             }
                                         })
      end
    end

    put '/api/orders/:code' do
      parameter :code,
                I18n.t('doc.orders.parameters.code'),
                required: true
      parameter :order_type_code,
                I18n.t('doc.orders.parameters.order_type_code'),
                scope: :order
      parameter :ext_code,
                I18n.t('doc.orders.parameters.ext_code'),
                scope: :order
      parameter :bp_id,
                I18n.t('doc.orders.parameters.bp_id'),
                scope: :order
      parameter :bp_state,
                I18n.t('doc.orders.parameters.bp_state'),
                scope: :order
      parameter :state,
                I18n.t('doc.orders.parameters.state'),
                {:scope                                         => :order,
                 I18n.t('doc.common.parameters.allowed_values') => Order.states.keys.join(', ')}
      parameter :done_at,
                I18n.t('doc.orders.parameters.done_at'),
                scope: :order
      parameter :archived,
                I18n.t('doc.orders.parameters.archived'),
                {:scope                                         => :order,
                 I18n.t('doc.common.parameters.allowed_values') => [true, false].join(', ')}
      parameter :data,
                I18n.t('doc.orders.parameters.data'),
                scope: :order

      let(:code)            { order_vacation_request.code }
      let(:order_type_code) { order_type_sup.code }
      let(:ext_code)        { 'ext_code' }
      let(:bp_id)           { 'bp_id' }
      let(:bp_state)        { 'bp_state' }
      let(:state)           { 'in_progress' }
      let(:archived)        { false }
      let(:data) do
        {
            'requesterName'  => 'Frank',
            'requesterPhone' => '123123123'
        }
      end

      example_request I18n.t('doc.common.cases.update') do
        explanation I18n.t('doc.orders.explanations.update')

        expect(status).to eq(200)

        updated_order = Order.find_by_id(order_vacation_request.id)
        expect(updated_order.ext_code).to eq(ext_code)
        expect(updated_order.bp_id).to    eq(bp_id)
        expect(updated_order.bp_state).to eq(bp_state)
        expect(updated_order.state).to    eq(state)
        expect(updated_order.done_at).to  eq(nil)
        expect(updated_order.archived).to eq(archived)
        expect(updated_order.data).to     eq({
                                                 'requesterName'  => 'Frank',
                                                 'requesterPhone' => '123123123',
                                                 'subject'        => nil,
                                                 'description'    => nil,
                                                 'resolution'     => nil,
                                                 'resolutionText' => nil
                                             })

        expect(JSON response_body).to eq(
                                          'order' => {
                                              'id'              => updated_order.id,
                                              'code'            => updated_order.code,
                                              'ext_code'        => updated_order.ext_code,
                                              'bp_id'           => updated_order.bp_id,
                                              'bp_state'        => updated_order.bp_state,
                                              'state'           => updated_order.state,
                                              'archived'        => updated_order.archived,
                                              'data'            => updated_order.data,
                                              'done_at'         => nil,
                                              'order_type_code' => updated_order.order_type.code,
                                              'user_email'      => nil
                                          })
      end
    end

    put '/api/orders/:code' do
      parameter :code,
                I18n.t('doc.orders.parameters.code'),
                required: true
      parameter :data,
                I18n.t('doc.orders.parameters.data'),
                scope: :order

      let(:code) { order_vacation_request.code }
      let(:data) do
        {
            'employeeFirstName' => 'James',
            'employeeLastName'  => 'Prinston',
            'employeeEmail'     => 'james@example.com',
            'beginDate'         => '2016-07-15T14:45:03.000+00:00',
            'endDate'           => '2016-07-16T14:49:42.000+00:00',
            'motivationText'    => 'I had a lot of work last 7 years',
            'resolution'        => nil,
            'resolutionText'    => nil,
            'adjustResult'      => nil,
            'jsonField'         => '{"last_name": "Carter"}'
        }
      end

      example_request I18n.t('doc.orders.cases.update_data') do
        expect(status).to eq(200)

        updated_order = Order.find_by_id(order_vacation_request.id)
        expect(updated_order.data).to eq(data)

        expect(JSON response_body).to eq(
                                          'order' => {
                                              'id'              => order_vacation_request.id,
                                              'code'            => order_vacation_request.code,
                                              'ext_code'        => order_vacation_request.ext_code,
                                              'bp_id'           => order_vacation_request.bp_id,
                                              'bp_state'        => order_vacation_request.bp_state,
                                              'state'           => order_vacation_request.state,
                                              'archived'        => order_vacation_request.archived,
                                              'data'            => data,
                                              'done_at'         => nil,
                                              'order_type_code' => order_vacation_request.order_type.code,
                                              'user_email'      => nil
                                          })
      end
    end


    put '/api/orders/:code' do
      parameter :code,
                I18n.t('doc.orders.parameters.code'),
                required: true
      parameter :user_email,
                I18n.t('doc.orders.parameters.user_email'),
                scope: :order

      let(:code)       { order_vacation_request.code }
      let(:user_email) { user_for_order.email }

      example_request I18n.t('doc.orders.cases.update_user_email') do
        expect(status).to eq(200)

        expect(order_vacation_request.user_id).not_to                  eq(user_for_order.id)
        expect(Order.find_by_id(order_vacation_request.id).user_id).to eq(user_for_order.id)

        expect(JSON response_body).to eq(
                                          'order' => {
                                              'id'              => order_vacation_request.id,
                                              'code'            => order_vacation_request.code,
                                              'ext_code'        => order_vacation_request.ext_code,
                                              'bp_id'           => order_vacation_request.bp_id,
                                              'bp_state'        => order_vacation_request.bp_state,
                                              'state'           => order_vacation_request.state,
                                              'archived'        => order_vacation_request.archived,
                                              'data'            => order_vacation_request.data,
                                              'done_at'         => nil,
                                              'order_type_code' => order_vacation_request.order_type.code,
                                              'user_email'      => user_email
                                          })
      end
    end

    let(:order_type) { FactoryGirl.create(:order_type, :active) }

    put '/api/orders/:code' do
      parameter :code,
                I18n.t('doc.orders.parameters.code'),
                required: true
      parameter :order_type_code,
                I18n.t('doc.orders.parameters.order_type_code'),
                scope: :order
      parameter :ext_code,
                I18n.t('doc.orders.parameters.ext_code'),
                scope: :order
      parameter :bp_id,
                I18n.t('doc.orders.parameters.bp_id'),
                scope: :order
      parameter :bp_state,
                I18n.t('doc.orders.parameters.bp_state'),
                scope: :order
      parameter :state,
                I18n.t('doc.orders.parameters.state'),
                {:scope => :order,
                 I18n.t('doc.common.parameters.allowed_values') => Order.states.keys.join(', ')}
      parameter :done_at,
                I18n.t('doc.orders.parameters.done_at'),
                scope: :order
      parameter :archived,
                I18n.t('doc.orders.parameters.archived'),
                {:scope                                         => :order,
                 I18n.t('doc.common.parameters.allowed_values') => [true, false].join(', ')}

      let(:code)            { order_vacation_request.code }
      let(:order_type_code) { order_type.code }
      let(:ext_code)        { 'ext_code' }
      let(:bp_id)           { 'bp_id' }
      let(:bp_state)        { 'bp_state' }
      let(:state)           { 'in_progress' }
      let(:done_at)         { Time.zone.now.iso8601 }
      let(:archived)        { false }

      example_request I18n.t('doc.orders.cases.update_base_fields') do
        expect(status).to eq(200)

        expect(order_vacation_request.order_type_id).not_to eq(order_type.id)
        updated_order = Order.find_by_id(order_vacation_request.id)
        expect(updated_order.order_type_id).to eq(order_type.id)
        expect(updated_order.ext_code).to      eq(ext_code)
        expect(updated_order.bp_id).to         eq(bp_id)
        expect(updated_order.bp_state).to      eq(bp_state)
        expect(updated_order.state).to         eq(state)
        expect(updated_order.done_at).to       eq(done_at)
        expect(updated_order.archived).to      eq(archived)

        expect(JSON response_body).to eq(
                                          'order' => {
                                              'id'              => updated_order.id,
                                              'code'            => updated_order.code,
                                              'ext_code'        => updated_order.ext_code,
                                              'bp_id'           => updated_order.bp_id,
                                              'bp_state'        => updated_order.bp_state,
                                              'state'           => updated_order.state,
                                              'archived'        => updated_order.archived,
                                              'data'            => {},
                                              'done_at'         => updated_order.done_at.iso8601,
                                              'order_type_code' => order_type.code,
                                              'user_email'      => nil
                                          })
      end
    end

  end
end
