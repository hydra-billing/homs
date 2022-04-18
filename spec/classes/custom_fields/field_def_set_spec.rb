describe CustomFields::FieldDefSet do
  let(:right_def) do
    (
      YAML.load <<~YML
                common: &common
                  required: true
                  multiple: false
                  visible:  true
                  editable: true
        #{'        '}
                order_type:
                  code: Подключение физического лица
                  fields:
                    my_field2:
                      type: 'string'
                      label: 'my_label2'
                      description: 'my_description2'
                      value: 'static content2'
                      <<: *common
      YML
    ).deep_symbolize_keys![:order_type][:fields]
  end

  let(:empty_def) do
    (
      YAML.load <<~YML
                common: &common
                  required: true
                  multiple: false
                  visible:  true
                  editable: true
        #{'        '}
                order_type:
                  code: Подключение физического лица
                  fields: {}
      YML
    ).deep_symbolize_keys![:order_type][:fields]
  end

  context 'Right definition' do
    let(:options) { right_def }
    it_behaves_like 'created from options' do
      it_behaves_like 'valid'
    end
  end

  context 'Invalid field definition' do
    let(:options) { right_def.dup.tap { |h| h[:my_field3] = '' } }
    it_behaves_like 'created from options' do
      it_behaves_like 'invalid' do
        it_behaves_like 'has errors' do
          let(:errors) do
            {
              my_field3: ["Attribute 'my_field3' should be of the Hash type"]
            }
          end
        end
      end
    end
  end

  context 'Empty field definition' do
    let(:options) { right_def.dup.tap { |h| h[:my_field3] = {} } }
    it_behaves_like 'created from options' do
      it_behaves_like 'invalid' do
        it_behaves_like 'has errors' do
          let(:errors) do
            {
              my_field3: ["my_field3: Missing attribute 'type', Missing attribute 'label'"]
            }
          end
        end
      end
    end
  end

  context 'Value for undefined field only' do
    let(:options) { empty_def }
    let(:attribute_name) { 'my_attribute' }
    let(:value) { {an_undefined_field: 'some string'} }

    it_behaves_like 'created from options' do
      it_behaves_like 'has validate value errors' do
        let(:errors) do
          {
            an_undefined_field: ['No fields left after ignoring unknown ones']
          }
        end
      end
    end
  end

  context 'Values with undefined field among defined ones' do
    let(:options) { right_def }
    let(:attribute_name) { 'my_attribute' }
    let(:value) { {an_undefined_field: 'some string', my_field2: ' value'} }

    it_behaves_like 'created from options' do
      it_behaves_like 'has no validate value errors'
    end
  end

  context 'Values with defined field' do
    let(:options) { right_def }
    let(:attribute_name) { 'my_field2' }
    let(:value) { {my_field2: 'some string'} }

    it_behaves_like 'created from options' do
      it_behaves_like 'has no validate value errors'
    end
  end
end
