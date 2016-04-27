shared_examples 'valid' do
  it 'valid? returns true' do
    expect(subject.valid?).to be true
  end
end

shared_examples 'invalid' do
  it 'valid? returns false' do
    expect(subject.valid?).to be false
  end
end
