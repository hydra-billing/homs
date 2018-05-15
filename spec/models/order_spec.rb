describe Order do
  let(:order_type) { FactoryBot.create(:order_type) }
  let(:order) { FactoryBot.create(:order, order_type: order_type) }

  after(:all) do
    OrderSequenceService.new.destroy
  end

  it '.id_from_code' do
    expect(Order.id_from_code(order.code)).to eq(order.id)
  end

  it '.states' do
    expect(Order.states.keys).to eq %w(to_execute in_progress done)
  end

  it '.state_i18n_key' do
    expect(Order.states.keys.map { |e| Order.state_i18n_key(e) }).to eq [
      'orders.states.to_execute',
      'orders.states.in_progress',
      'orders.states.done'
    ]
  end

  # Order#data default nil values ->

  let(:order_type_vacation_request) do
    FactoryBot.create(:order_type, :vacation_request)
  end

  let(:order_vacation_request) do
    FactoryBot.create(:order, order_type: order_type_vacation_request)
  end

  it '#data should have default nil values for all defined fields' do
    expect(order_vacation_request.data).to eq('vacationLeaveDate' => nil,
                                              'vacationBackDate' => nil,
                                              'employee' => nil,
                                              'approver' => nil)
  end

  it '#data=(value) should merge the value, not overwrite with it' do
    order_vacation_request.data = { approver: 'kermit' }
    expect(order_vacation_request.data).to eq('vacationLeaveDate' => nil,
                                              'vacationBackDate' => nil,
                                              'employee' => nil,
                                              'approver' => 'kermit')
  end
  # <-
end
