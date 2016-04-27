shared_examples 'has options' do
  it 'being called :options returns right options' do
    expect(subject.options).to eq options
  end
  it { is_expected.to respond_to(:[]) }
end
