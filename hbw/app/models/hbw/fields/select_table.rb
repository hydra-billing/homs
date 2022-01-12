module HBW
  module Fields
    class SelectTableContract < Dry::Validation::Contract
      schema do
        required(:rows).array(:hash) do
          required(:name).filled(:string)
          optional(:type).maybe(included_in?: %w(string number date))
          optional(:alignment).maybe(included_in?: %w(left center right))

          # number specific attributes
          optional(:precision).maybe(:integer)
          optional(:separator).maybe(:string)
          optional(:delimiter).maybe(:string)

          # date specific attributes
          optional(:format).maybe(:string)
        end
      end

      rule(:rows).each do
        key.failure('invalid number') if value[:type] && value[:type] != 'number' && (value[:separator] || value[:delimiter] || value[:precision])

        key.failure('invalid date') if value[:type] && value[:type] != 'date' && value[:format]
      end
    end

    class SelectTable < Select
      include ActionView::Helpers::NumberHelper

      self.default_data_type = :string

      attr_reader :choices, :rows

      definition_reader :sql, :variable, :entity_class

      class_attribute :contract

      self.contract = SelectTableContract.new

      def as_json
        {name:          name,
         type:          type,
         mode:          mode,
         label:         label,
         css_class:     css_class,
         placeholder:   placeholder,
         label_css:     label_css,
         choices:       processed_choices,
         description:   description,
         row_params:    rows,
         nullable:      nullable?,
         editable:      editable?,
         delimiter:     delimiter?,
         delete_if:     delete_if,
         disable_if:    disable_if,
         dynamic:       dynamic,
         variables:     variables,
         current_value: value,
         url:           url,
         multi:         multi}
      end

      def processed_choices
        defaultify_row_params

        choices.map do |line|
          line.each_with_index.map do |item, idx|
            if idx.zero?
              item.to_i
            else
              config = rows[idx - 1]

              case config[:type]
              when 'number' then prepare_number(item, config)
              when 'date' then prepare_date(item, config)
              else item
              end
            end
          end
        end
      end

      private

      def mode
        'select'
      end

      def multi
        definition.fetch('multi', false)
      end

      def choices_to_array(choices)
        choices.map do |variant|
          variant.delete(:id)
          variant.delete(:text)

          variant.values
        end.uniq
      end

      def defaultify_row_params
        @rows ||= definition.fetch('rows').map(&:deep_symbolize_keys!).map do |config|
          if config[:type].nil?
            config[:type] = 'string'
          end

          config
        end

        unless contract.(rows: rows).success?
          raise StandardError, 'Wrong config for select table'
        end
      end

      def prepare_date(item, config)
        unless item.nil?
          date = Time.iso8601(item)
          if config[:format]
            date.strftime(config[:format])
          else
            I18n.l(date)
          end
        end
      end

      def prepare_number(item, config)
        number_to_currency(item,
                           precision: config[:precision] || 0,
                           separator: config[:separator] || ',',
                           delimiter: config[:delimiter] || '',
                           unit:      '')
      end
    end
  end
end
