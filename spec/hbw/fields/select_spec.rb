describe HBW::Fields::Select do
  let(:field) do
    definition = YAML.load '
name: homsOrderDataMarketingSource
type: select
label: Marketing source
css_class: col-xs-6 col-sm-4 col-md-3
choices:
  -
    - Friends recommendation
    - Friends recommendation
  -
    - Internet search
    - Internet search'
    HBW::Fields::Base.wrap definition
  end

  it 'fetches choices' do
    expect(field.fetch). to eq([['Friends recommendation', 'Friends recommendation'],
                                ['Internet search', 'Internet search']])
  end
end
