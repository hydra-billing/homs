require 'dry-validation'

module HBW
  class ConfigValidator
    EntitySchema = Dry::Validation.Schema do
      required(:entity_code_key).filled(:str?)
      required(:task_list).schema do
        required(:entity_url).filled(:str?)
        required(:entity_url_params).each(:str?)
        optional(:group_by_var).filled(:str?)
      end
      optional(:bp_toolbar).schema do
        optional(:entity_type_buttons).schema
        optional(:common_buttons).each do
          schema do
            required(:name).filled(:str?)
            required(:bp_code).filled(:str?)
            optional(:title).filled(:str?)
            optional(:class).filled(:str?)
            optional(:fa_class).filled(:str?)
          end
        end
      end
    end

    ConfigSchema = Dry::Validation.Schema do
      required(:hbw).schema do
        required(:entities).schema
        optional(:use_bpm_stub).filled(:bool?)
        optional(:minio).schema do
          optional(:endpoint).maybe(:str?)
          optional(:access_key_id).maybe(:str?)
          optional(:secret_access_key).maybe(:str?)
          optional(:bucket).maybe(:str?)
          optional(:region).maybe(:str?)
        end
      end
    end

    class << self
      def call(config)
        validated_config = ConfigSchema.(config)

        raise "Application misconfigured: #{validated_config.errors.to_h}" if validated_config.failure?

        config[:hbw][:entities].each do |name, entity_config|
          validated_entity = EntitySchema.(entity_config)

          raise "Entity #{name} misconfigured: #{validated_entity.errors}" if validated_entity.failure?
        end

        validated_config
      end
    end
  end
end
