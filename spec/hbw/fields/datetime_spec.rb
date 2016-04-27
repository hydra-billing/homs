describe HBW::Fields::Datetime do
  let(:field) do
    definition = YAML.load '
name: homsOrderDataBeginDate
type: datetime
label: Begin Date
css_class: col-xs-6 col-sm-4 col-md-3
format: DD.MM.YYYY'
    HBW::Fields::Base.wrap definition
  end

  it 'coerces empty strings' do
    expect(field.coerce('')).to eq(nil)
  end

  it 'coerces nil strings' do
    expect(field.coerce(nil)).to eq(nil)
  end
end
