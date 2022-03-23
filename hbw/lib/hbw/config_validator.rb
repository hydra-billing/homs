require 'dry-schema'

module HBW
  class ConfigValidator
    EntitySchema = Dry::Schema.JSON do
      required(:entity_code_key).filled(:string)
      required(:bp_name_key).filled(:string)
      required(:task_list).hash do
        required(:entity_url).filled(:string)
        required(:entity_url_params).each(:string)
      end
      optional(:bp_toolbar).hash do
        optional(:entity_type_buttons).hash
        optional(:common_buttons).each do
          schema do
            required(:name).filled(:string)
            required(:bp_code).filled(:string)
            optional(:title).filled(:string)
            optional(:class).filled(:string)
            optional(:fa_class).filled(:string)
          end
        end
      end
    end

    ConfigSchema = Dry::Schema.JSON do
      required(:hbw).hash do
        required(:entities).hash
        optional(:use_bpm_stub).filled(:bool)
        optional(:minio).hash do
          optional(:endpoint).maybe(:string)
          optional(:access_key_id).maybe(:string)
          optional(:secret_access_key).maybe(:string)
          optional(:bucket).maybe(:string)
          optional(:region).maybe(:string)
        end
        required(:allowed_request_origins).each(:string)
        optional(:candidate_starters).hash do
          optional(:enabled).filled(:bool)
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
