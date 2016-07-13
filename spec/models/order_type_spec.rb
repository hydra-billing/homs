require 'rails_helper'

RSpec.describe OrderType, type: :model do
  it '.new' do
    # right usage
    #

    right_file = {
      order_type: {
          code: 'Charge',
          name: 'Charge',
          print_form_code: 'Print form code',
          fields: { any_hash: :x }
      }
    }.to_yaml
    allow_any_instance_of(CustomFields::FieldDefSet)
      .to receive(:validate_definition)
      .and_return(true)
    ot = OrderType.new(file: right_file)
    expect(ot.valid?).to be true
    expect(ot.code).to eq('Charge')
    expect(ot.print_form_code).to eq('Print form code')
    expect(ot.fields).to eq(any_hash: :x)
    expect(ot.errors.full_messages).to be_empty

    # wrong usage
    #
    [
      'Just a string',
      'That leads to parsing error: &',
      {}.to_yaml,
      nil
    ].each do |wrong_file|
      ot = OrderType.new(file: wrong_file.to_yaml)
      expect(ot.valid?).to be false
      expect(ot.errors.full_messages).to eq [
        "Uploaded YAML file content [\"Missing attribute 'order_type'\"]"
      ]
    end

    ot = OrderType.new(file: { order_type: 1 }.to_yaml)
    expect(ot.valid?).to be false
    expect(ot.errors.full_messages).to eq [
      "Uploaded YAML file content [\"Attribute 'order_type' should be "\
      "of Hash type\"]"
    ]

    ot = OrderType.new(file: { order_type: {} }.to_yaml)
    expect(ot.valid?).to be false
    expect(ot.errors.full_messages).to eq [
      "Uploaded YAML file content [\"Missing attribute 'fields'\", "\
      "\"Missing attribute 'code'\", \"Missing attribute 'name'\"]"
    ]

    ot = OrderType.new(file: { order_type: { code: 'Charge' } }.to_yaml)
    expect(ot.valid?).to be false
    expect(ot.code).to eq(nil)
    expect(ot.fields).to eq(nil)
    expect(ot.errors.full_messages).to eq [
      "Uploaded YAML file content [\"Missing attribute 'fields'\", \"Missing attribute 'name'\"]"
    ]

    ot = OrderType.new(file: {
      order_type: {
        code: 'Charge',
        name: 'Charge',
        fields: {}
      }
    }.to_yaml)
    expect(ot.valid?).to be true
    expect(ot.code).to eq('Charge')
    expect(ot.fields).to eq({})
  end

  it '.id_from_code' do
    active_c1   = FactoryGirl.create(:order_type, :active,  code: 'C1')
    FactoryGirl.create(:order_type, code: 'C1')
    FactoryGirl.create(:order_type, code: 'C2')

    expect(OrderType.id_from_code('C1')).to eq(active_c1.id)
    expect(OrderType.id_from_code('C2')).to be_nil
  end

  it '.lookup' do
    FactoryGirl.create(:order_type, code: 'Vacation request', name: 'Vacation request')
    FactoryGirl.create(:order_type, code: 'Support Request', name: 'Support Request')
    a_c2 = FactoryGirl.create(:order_type, :active,  code: 'Support Request', name: 'Support Request')
    a_c1 = FactoryGirl.create(:order_type, :active,  code: 'Vacation request', name: 'Vacation request')

    expect(OrderType.lookup('va')).to eq([{ id: a_c1.id, text: a_c1.code }])
    expect(OrderType.lookup('su')).to eq([{ id: a_c2.id, text: a_c2.code }])
    expect(OrderType.lookup('req')).to eq([
                                              { id: a_c2.id, text: a_c2.code },
                                              { id: a_c1.id, text: a_c1.code }
                                          ])
    expect(OrderType.lookup('dis')).to eq([])
  end
end
