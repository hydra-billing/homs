module HBW
  module Fields
    class SelectTable < Select
      include ActionView::Helpers::NumberHelper

      self.default_data_type = :string

      attr_reader :choices, :rows
      definition_reader :sql
      definition_reader :variable
      definition_reader :entity_class

      class << self
        def schema
          @schema = Dry::Validation.Schema do
            each do
              schema do
                configure do
                  def correct_type?(value)
                    value.in? %w(string number date)
                  end

                  def correct_alignment?(value)
                    value.in? %w(left center right)
                  end
                end

                required(:name).filled(:str?)
                optional(:type).maybe(:correct_type?)
                optional(:alignment).maybe(:correct_alignment?)

                # number specific attributes
                optional(:precision).maybe(:int?)
                optional(:separator).maybe(:str?)
                optional(:delimiter).maybe(:str?)

                # date specific attributes
                optional(:format).maybe(:str?)

                validate(valid_number: %i[delimiter separator precision type]) do |t_sep, d_sep, precision, type|
                  type == 'number' || (t_sep.nil? && d_sep.nil? && precision.nil?)
                end

                validate(valid_date: %i[format type]) do |format, type|
                  type == 'date' || format.nil?
                end
              end
            end
          end
        end
      end

      def as_json
        { name: name,
          type: type,
          mode: mode,
          label: label,
          css_class: css_class,
          placeholder: placeholder,
          label_css: label_css,
          choices: processed_choices,
          row_params: rows,
          nullable: nullable?,
          editable: editable?,
          delimiter: delimiter?,
          delete_if: delete_if,
          disable_if: disable_if,
          variables: task.definition['variables'],
          current_value: value,
          url: url,
          multi: multi }
      end

      def processed_choices
        defaultify_row_params

        choices.map do |line|
          line.each_with_index.map do |item, idx|
            if idx != 0
              config = rows[idx - 1]

              case config[:type]
                when 'number' then prepare_number(item, config)
                when 'date' then prepare_date(item, config)
                else item
              end
            else
              item.to_i
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

        unless self.class.schema.(rows).success?
          raise Exception.new('Wrong config for select table')
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
                           unit: '')
      end
    end
  end
end
