shared_examples 'created from options' do
  let(:subject) { described_class.new options }
  it_behaves_like 'has options'
end
