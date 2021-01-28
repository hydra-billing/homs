module CustomFields
  module DataTypes
    describe CustomFields::DataTypes::Number do
      let(:attribute_name) { 'my_number' }

      # definition validation
      context 'Valid definition' do
        let(:options) { {} }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'valid'
          it_behaves_like 'has no errors'
        end
      end

      # value validation
      context 'nil value validation' do
        let(:options) { {} }
        let(:value) { nil }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'has no errors'
        end
      end

      context 'Wrong number value validation' do
        let(:options) { {} }
        let(:value) { 'just not a number' }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'has validate value errors' do
            let(:errors) do
              {
                'my_number' => [
                  "Attribute 'my_number' has the invalid value 'just not a number'"
                ]
              }
            end
          end
        end
      end
    end
  end
end
