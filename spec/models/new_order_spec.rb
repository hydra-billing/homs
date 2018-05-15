describe 'create new order' do
  let(:order_type) { FactoryBot.build(:order_type, :support_request) }
  let(:order)      { FactoryBot.build(:order, order_type: order_type) }

  describe 'with errors in' do
    it 'number field' do
      order[:data]['contractNumber'] = 'not a number'
      expect(order.valid?).to eq(false)
      expect(order.errors[:data][0]['contractNumber'][0]).to eq("Attribute 'contractNumber' has invalid value 'not a number'")
      order[:data]['contractNumber'] = nil
    end

    it 'datetime field' do
      order[:data]['creationDate'] = 'bad date'
      expect(order.valid?).to eq(false)
      expect(order.errors[:data][0]['creationDate'][0]).to eq("Attribute 'creationDate' with value 'bad date' should be of DateTime type")
      order[:data]['creationDate'] = nil
    end

    it 'boolean field' do
      order[:data]['callBack'] = 'qwerty'
      expect(order.valid?).to eq(false)
      expect(order.errors[:data][0]['callBack'][0]).to eq("Attribute 'callBack' with value 'qwerty' should be one of [\"true\", \"false\", \"on\", \"off\", \"1\", \"0\"]")
      order[:data]['callBack'] = nil
    end
  end

  describe 'without error' do
    it 'for empty fields' do
      expect(order.valid?).to eq(true)
    end

    it 'for valid fields' do
      order[:data]['contractNumber'] = '123'
      order[:data]['creationDate']   = '2016-03-31T17:42:29.000+03:00'
      order[:data]['callBack']       = '1'
      expect(order.valid?).to eq(true)
    end
  end
end
