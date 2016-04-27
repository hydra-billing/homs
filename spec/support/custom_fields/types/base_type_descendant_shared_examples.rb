shared_examples 'a CustomFields::Base descendant' do
  let(:subject) do
    errors = {}
    described_class.new(options, errors)
  end
  it_behaves_like 'has options'
end
