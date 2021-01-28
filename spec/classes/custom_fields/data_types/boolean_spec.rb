module CustomFields
  module DataTypes
    describe CustomFields::DataTypes::Boolean do
      let(:attribute_name) { 'my_checkbox' }

      # definition validation with default: true
      describe 'Testing valid definition with default true' do
        context 'Valid definition with default true' do
          let(:options) { {default: true} }

          it_behaves_like 'a CustomFields::Base descendant' do
            it_behaves_like 'valid'
            it_behaves_like 'has no errors'
          end
        end
      end

      describe 'Testing valid definition with default false' do
        context 'Valid definition with default false' do
          let(:options) { {default: false} }

          it_behaves_like 'a CustomFields::Base descendant' do
            it_behaves_like 'valid'
            it_behaves_like 'has no errors'
          end
        end
      end

      describe 'Testing valid definition without default (empty options)' do
        context 'Valid definition without default (empty options)' do
          let(:options) { {} }

          it_behaves_like 'a CustomFields::Base descendant' do
            it_behaves_like 'valid'
            it_behaves_like 'has no errors'
          end
        end
      end

      # definition validation

      describe 'Testing nil value validation' do
        context 'nil value validation' do
          let(:options) { {} }
          let(:value) { nil }
          it_behaves_like 'a CustomFields::Base descendant' do
            it_behaves_like 'has validate value errors' do
              let(:errors) do
                {}
              end
            end
          end
        end
      end

      describe 'Testing unexpected value validation' do
        context 'Unexpected value validation' do
          let(:options) { {default: true} }
          let(:value) { 'Some string' }
          it_behaves_like 'a CustomFields::Base descendant' do
            it_behaves_like 'has validate value errors' do
              let(:errors) do
                {
                  'my_checkbox' => ["Attribute 'my_checkbox' with the value 'Some string' must have a value \
from the list [\"true\", \"false\", \"on\", \"off\", \"1\", \"0\"]"]
                }
              end
            end
          end
        end
      end

      describe 'Testing valid value validation with default false' do
        context 'Valid value validation' do
          let(:options) { {default: false} }
          let(:value) { true }
          it_behaves_like 'a CustomFields::Base descendant' do
            it_behaves_like 'has no validate value errors'
          end
        end
      end

      describe 'Testing valid value validation with default true' do
        context 'Valid value validation' do
          let(:options) { {default: true} }
          let(:value) { false }
          it_behaves_like 'a CustomFields::Base descendant' do
            it_behaves_like 'has no validate value errors'
          end
        end
      end
    end
  end
end
