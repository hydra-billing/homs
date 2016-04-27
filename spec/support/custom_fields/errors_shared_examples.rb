shared_examples 'has errors' do
  it 'being called :errors returns right errors' do
    expect(subject.errors).to eq(errors)
  end
end

shared_examples 'has no errors' do
  it 'errors object is empty' do
    expect(subject.errors.empty?).to be true
  end
end

shared_examples 'has validate value errors' do
  it 'being called :errors returns right errors' do
    subject.validate_value attribute_name, value
    expect(subject.errors).to eq(errors)
  end
end

shared_examples 'has no validate value errors' do
  it 'errors object is empty' do
    subject.validate_value attribute_name, value
    expect(subject.errors.empty?).to be true
  end
end
