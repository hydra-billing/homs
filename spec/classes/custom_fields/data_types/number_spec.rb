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

      # Valid string number values
      context 'Valid integer string values' do
        let(:options) { {} }

        ['100', '0', '-50', '1'].each do |test_value|
          context "with value '#{test_value}'" do
            let(:value) { test_value }
            it_behaves_like 'a CustomFields::Base descendant' do
              it_behaves_like 'has no errors'
            end
          end
        end
      end

      context 'Valid decimal string values' do
        let(:options) { {} }

        ['100.5', '3.14', '-2.5', '0.1'].each do |test_value|
          context "with value '#{test_value}'" do
            let(:value) { test_value }
            it_behaves_like 'a CustomFields::Base descendant' do
              it_behaves_like 'has no errors'
            end
          end
        end
      end

      context 'Valid string values with trailing zeros' do
        let(:options) { {} }

        ['100.0', '100.00', '0.0', '0.00', '100.500'].each do |test_value|
          context "with value '#{test_value}'" do
            let(:value) { test_value }
            it_behaves_like 'a CustomFields::Base descendant' do
              it_behaves_like 'has no errors'
            end
          end
        end
      end

      context 'Valid numeric values' do
        let(:options) { {} }

        [100, 0, -50, 100.5, 3.14, -2.5].each do |test_value|
          context "with value #{test_value}" do
            let(:value) { test_value }
            it_behaves_like 'a CustomFields::Base descendant' do
              it_behaves_like 'has no errors'
            end
          end
        end
      end

      # Invalid string values
      context 'Invalid string values' do
        let(:options) { {} }

        ['', '100abc', 'abc100', '.', ' 100 ', '100 ', ' 100', '00100', '+100', '1e10'].each do |test_value|
          context "with value '#{test_value}'" do
            let(:value) { test_value }
            it_behaves_like 'a CustomFields::Base descendant' do
              it_behaves_like 'has validate value errors' do
                let(:errors) do
                  {
                    'my_number' => [
                      "Attribute 'my_number' has the invalid value '#{test_value}'"
                    ]
                  }
                end
              end
            end
          end
        end
      end
    end
  end
end
