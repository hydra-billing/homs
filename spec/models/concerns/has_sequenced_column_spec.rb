describe HasSequencedColumn do
  before(:each) do
    @model = Temping.create :test_model
    @model.send :include, HasSequencedColumn
  end

  after(:each) do
    Object.send(:remove_const, :TestModel)
  end

  it 'defines .has_sequenced_column only method on inclusion' do
    expect(@model).to respond_to(:has_sequenced_column)
    expect(@model).not_to respond_to(:sequenced_column)
    expect(@model).not_to respond_to(:sequenced_column=)
  end

  it 'defines few class methods when .has_sequenced_column called' do
    @model.has_sequenced_column
    expect(@model).to respond_to(:sequenced_column)
    expect(@model).to respond_to(:sequenced_column=)
  end

  it '.has_sequenced_column defines :before_create callback' do
    expect(@model).to receive(:before_create)
    @model.has_sequenced_column :my_column
  end

  it 'Model column gets value from sequence before model obj being saved' do
    @model.has_sequenced_column :my_column

    expect(Sequence).to receive(:nextval).with(@model)
      .and_return('FX-12345')

    expect_any_instance_of(@model).to receive(:[]=)
      .with(:my_column, 'FX-12345')
    @model.create
  end
end
