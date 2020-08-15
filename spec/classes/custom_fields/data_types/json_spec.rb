module CustomFields
  module DataTypes
    describe CustomFields::DataTypes::Json do
      let(:attribute_name) { 'my_json' }

      # definition validation
      context 'Valid definition' do
        let(:options) { { } }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'valid'
          it_behaves_like 'has no errors'
        end
      end

      # value validation
      context 'nil value validation' do
        let(:options) { { } }
        let(:value) { nil }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'has no errors'
        end
      end

      context 'Wrong JSON value validation' do
        let(:options) { { } }
        let(:value) { 'just not a json' }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'has validate value errors' do
            let(:errors) do
              {
                  'my_json' => [
                      'Attribute my_json has invalid value just not a json. Not a valid JSON.'
                  ]
              }
            end
          end
        end
      end

      context 'Valid value validation' do
        let(:options) { { } }
        let(:value) { '{"test": 1}' }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'has no errors'
        end
      end
    end
  end
end
