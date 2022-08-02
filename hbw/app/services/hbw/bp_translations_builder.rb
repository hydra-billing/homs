module HBW
  class BPTranslationsBuilder
    TRANSLATIONS_DIR = Rails.root.join('config', 'locales', 'bp').freeze
    LOCALES = [:en, :ru, :es].freeze

    class << self
      def call
        Dir.children(TRANSLATIONS_DIR).inject(initial) do |all_translations, filename|
          bp_translations = YAML.load_file(File.join(TRANSLATIONS_DIR, filename)).deep_symbolize_keys

          merge_translations!(all_translations, bp_translations)
        end
      end

      private

      def initial
        LOCALES.each_with_object({}) { |locale, acc| acc[locale] = {} }
      end

      def merge_translations!(to, from)
        LOCALES.each_with_object(to) do |locale, acc|
          acc[locale].merge!(from[locale] || {})
        end
      end
    end
  end
end
