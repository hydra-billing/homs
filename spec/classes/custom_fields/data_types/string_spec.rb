module CustomFields
  module DataTypes
    describe CustomFields::DataTypes::String do
      let(:attribute_name) { 'my_string' }
      let(:max_length) { CustomFields::DataTypes::String::MAX_LENGTH }

      # definition validation
      context 'Valid definition' do
        let(:options) { {default: 'Some value'} }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'valid'
          it_behaves_like 'has no errors'
        end
      end

      context 'Empty definition' do
        let(:options) { {} }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'valid'
          it_behaves_like 'has no errors'
        end
      end

      context 'Maximum length default string in a definition' do
        let(:options) { {default: 's' * max_length} }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'valid'
          it_behaves_like 'has no errors'
        end
      end

      context 'Too long default string in a definition' do
        let(:options) { {default: 's' * (max_length + 1)} }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'invalid'
          it_behaves_like 'has errors' do
            let(:errors) do
              {
                default: ["Attribute 'default' must not exceed #{max_length} characters"]
              }
            end
          end
        end
      end

      context 'Maximum allowed string length in string definition' do
        let(:options) do
          {max_length: max_length}
        end

        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'valid'
          it_behaves_like 'has no errors'
        end
      end

      context 'Too big string max_length in a definition' do
        let(:options) do
          {max_length: max_length + 1}
        end

        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'invalid'
          it_behaves_like 'has errors' do
            let(:errors) do
              {
                max_length: ["Attribute 'max_length' must not exceed " \
                             "#{max_length} characters"]
              }
            end
          end
        end
      end

      # Allow mask to be defined
      # Do not enforce value to fit the mask, as there are many
      # ways to define a mask. Depends on UI plugin
      context 'Mask in string definition' do
        let(:options) do
          {mask: '(999) 999-99-99'}
        end

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

      context 'Too long string value validation' do
        let(:options) { {} }
        let(:value) { 's' * (max_length + 1) }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'has validate value errors' do
            let(:errors) do
              {
                'my_string' => [
                  "Attribute 'my_string' must not exceed #{max_length} characters"
                ]
              }
            end
          end
        end
      end

      context 'Maximum length string value validation' do
        let(:options) { {} }
        let(:value) { 's' * max_length }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'has no validate value errors'
        end
      end

      context 'Empty string value validation' do
        let(:options) { {} }
        let(:value) { '' }
        it_behaves_like 'a CustomFields::Base descendant' do
          it_behaves_like 'has no validate value errors'
        end
      end
    end
  end
end
