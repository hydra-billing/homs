require 'dry-validation'

module BPM
  class ConfigValidator
    class ConfigContract < Dry::Validation::Contract
      params do
        required(:config).value(:array, min_size?: 1).each do
          hash do
            required(:name).filled(:string)
            required(:url).filled(:string, format?: URI::DEFAULT_PARSER.make_regexp(%w[http https]))
            required(:login).filled(:string)
            required(:password).filled(:string)
            required(:process_definitions).array(:string)
          end
        end
      end

      rule(:config) do
        names = value.map { |c| c[:name] }
        urls = value.map { |c| c[:url] }
        process_definitions = value.flat_map { |c| c[:process_definitions] }

        if names.uniq.length != names.length
          key.failure('Names must be unique')
        end

        if urls.uniq.length != urls.length
          key.failure('URLs must be unique')
        end

        if process_definitions.uniq.length != process_definitions.length
          key.failure('Process definitions must be unique')
        end
      end
    end

    class << self
      def call(input)
        contract = ConfigContract.new
        validated = contract.call(input)

        if validated.failure?
          raise "Application misconfigured: #{validated.errors.to_h}"
        else
          validated.to_h[:config]
        end
      end
    end
  end
end
