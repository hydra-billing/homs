describe CustomFields::FieldDef do
  let(:right_def) do
    {
      name:        'my_field',
      type:        'string',
      label:       'my_label',
      description: 'my_description',
      value:       'string content',
      required:    true,
      multiple:    false,
      visible:     true,
      editable:    true
    }
  end
  let(:unexpected)    { right_def.dup.tap { |h| h[:name] = 1 } }
  let(:unknown)       { right_def.dup.tap { |h| h[:type] = 'bad_type' } }
  let(:missing_type)  { right_def.dup.tap { |h| h.delete(:type) } }
  let(:missing_name)  { right_def.dup.tap { |h| h.delete(:name) } }

  it 'Right definition should have certain getters' do
    fd = CustomFields::FieldDef.new right_def
    expect(fd[:name]).to eq 'my_field'
    expect(fd[:type]).to eq 'string'
    expect(fd[:label]).to eq 'my_label'
    expect(fd[:description]).to eq 'my_description'
    expect(fd[:value]).      to eq 'string content'
    expect(fd[:required]).to eq true
    expect(fd[:multiple]).to eq false
    expect(fd[:visible]).to eq true
    expect(fd[:editable]).to eq true
  end

  it 'Wrong definition should have certain getters' do
    fd = CustomFields::FieldDef.new({})
    expect(fd[:name]).to eq nil
    expect(fd[:type]).to eq nil
    expect(fd[:label]).to eq nil
    expect(fd[:description]).to eq nil
    expect(fd[:value]).to eq nil
    expect(fd[:required]).to eq nil
    expect(fd[:multiple]).to eq nil
    expect(fd[:visible]).to eq nil
    expect(fd[:editable]).to eq nil
  end

  it 'Right definition should be valid, errors should be empty' do
    fd = CustomFields::FieldDef.new right_def
    expect(fd.valid?).to be true
    expect(fd.errors).to be_empty
  end

  it 'Unknown type should appear in errros' do
    fd = CustomFields::FieldDef.new unknown
    expect(fd.valid?).to be false
    expect(fd.errors).to eq Hash('bad_type' => ["Unknown type 'bad_type'"])
  end

  it 'Missing attributes should appear in errors' do
    fd = CustomFields::FieldDef.new({})
    expect(fd.valid?).to be false
    expect(fd.errors).to eq Hash(
      label: ["Missing attribute 'label'"],
      name:  ["Missing attribute 'name'"],
      type:  ["Missing attribute 'type'"]
    )
  end

  it 'Missing :type attribute should only appear in errors' do
    fd = CustomFields::FieldDef.new missing_type
    expect(fd.valid?).to be false
    expect(fd.errors).to eq Hash(type: ["Missing attribute 'type'"])
  end

  it 'Unexpected attribute type should appear in errors' do
    fd = CustomFields::FieldDef.new unexpected
    expect(fd.valid?).to be false
    expect(fd.errors)
      .to eq Hash(
        name: ["Attribute 'name' should be of the String type"]
      )
  end

  it 'Missing type specific attribute should appear in errors' do
    fd = CustomFields::FieldDef.new missing_name
    expect(fd.valid?).to be false
    expect(fd.errors).to eq Hash(name: ["Missing attribute 'name'"])
  end
end
