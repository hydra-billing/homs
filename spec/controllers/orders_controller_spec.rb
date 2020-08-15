describe OrdersController, type: :controller do
  let(:order_type) { FactoryBot.create(:order_type, :support_request) }
  let(:order)      { FactoryBot.build(:order, order_type: order_type) }
  let(:user)       { FactoryBot.create(:user) }

  describe 'Orders' do
    render_views

    it 'create success' do
      sign_in user

      order[:data]['contractNumber'] = '123'
      order[:data]['creationDate']   = '2016-03-31T17:42:29.000+03:00'
      order[:data]['callBack']       = '1'

      post 'create', params: {order: {data: order[:data]}, order_type_id: order_type.id}
      expect(subject).to redirect_to("/orders/#{Order.last.code}")
    end

    it 'create failure' do
      sign_in user

      order[:data]['contractNumber'] = 'qwerty'
      order[:data]['creationDate']   = '2016-03-31T17:42:29.000+03:00'
      order[:data]['callBack']       = '1'

      post 'create', params: {order: {data: order[:data]}, order_type_id: order_type.id}
      expect(response.body).to match /has the invalid value/im
    end

    it 'update success' do
      sign_in user

      unless order.save
        raise Exception('Order is not saved')
      end

      expect(Order.find_by_id(order.id)[:data]['contractNumber']).to eq(nil)
      expect(Order.find_by_id(order.id)[:data]['creationDate']).to   eq(nil)
      expect(Order.find_by_id(order.id)[:data]['callBack']).to       eq(nil)

      order[:data]['contractNumber'] = '123'
      order[:data]['creationDate']   = '2016-03-31T17:42:29.000+03:00'
      order[:data]['callBack']       = '1'

      patch 'update', params: {id: order.code, order: {data: order[:data]}}

      expect(Order.find_by_id(order.id)[:data]['contractNumber']).to eq(123)
      expect(Order.find_by_id(order.id)[:data]['creationDate']).to   eq('2016-03-31T17:42:29.000+03:00')
      expect(Order.find_by_id(order.id)[:data]['callBack']).to       eq(true)
    end
  end
end
