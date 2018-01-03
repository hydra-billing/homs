describe HBW::Fields::SelectTable do
  let(:field) do
    definition = YAML.load '
name: homsOrderDataMarketingSource
type: select_table
label: Marketing source
css_class: col-xs-12
rows:
  - name: Name
    type: string
    alignment: right
  - name: Code
  - name: Some number
    type: number
    precision: 2
    separator: "."
    delimiter: ","
  - name: Some date
    type: date
    format: "%Y"
choices:
  -
    - 125342501
    - Friends recommendation name
    - Friends recommendation code
    - 5000
    - "2018-01-14T13:17:28+03:00"
  -
    - 125342601
    - Internet search name
    - Internet search code
    - 7000
    - "2017-01-14T13:12:41+03:00"'
    HBW::Fields::Base.wrap definition
  end

  it 'fetches choices' do
    field.fetch
    expect(field.processed_choices). to eq([[125342501, 'Friends recommendation name', 'Friends recommendation code', '5,000.00', '2018'],
                                            [125342601, 'Internet search name', 'Internet search code', '7,000.00', '2017']])
  end

  let(:field_with_wrong_type) do
    definition = YAML.load '
name: homsOrderDataMarketingSource
type: select_table
label: Marketing source
css_class: col-xs-12
rows:
  - name: Name
    type: metatype
    alignment: right
choices:
  -
    - 125342501
    - Friends recommendation name
  -
    - 125342601
    - Internet search name'
    HBW::Fields::Base.wrap definition
  end

  it 'raises validation error for type' do
    field.fetch
    expect { field_with_wrong_type.processed_choices }.to raise_error(Exception, 'Wrong config for select table')
  end

  let(:field_with_wrong_option_from_number_for_string) do
    definition = YAML.load '
name: homsOrderDataMarketingSource
type: select_table
label: Marketing source
css_class: col-xs-12
rows:
  - name: Name
    type: string
    alignment: right
    delimiter: ","
choices:
  -
    - 125342501
    - Friends recommendation name
  -
    - 125342601
    - Internet search name'
    HBW::Fields::Base.wrap definition
  end

  it 'raises validation error for wrong option from number for string' do
    field.fetch
    expect { field_with_wrong_option_from_number_for_string.processed_choices }.to raise_error(Exception, 'Wrong config for select table')
  end

  let(:field_with_wrong_option_from_date_for_string) do
    definition = YAML.load '
name: homsOrderDataMarketingSource
type: select_table
label: Marketing source
css_class: col-xs-12
rows:
  - name: Name
    type: string
    alignment: right
    format: "%Y"
choices:
  -
    - 125342501
    - Friends recommendation name
  -
    - 125342601
    - Internet search name'
    HBW::Fields::Base.wrap definition
  end

  it 'raises validation error for wrong option from date for string' do
    field.fetch
    expect { field_with_wrong_option_from_date_for_string.processed_choices }.to raise_error(Exception, 'Wrong config for select table')
  end
end
