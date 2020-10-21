module Features
  module I18nHelper
    def set_locale(locale)
      I18n.default_locale = locale
    end

    def reset_locale
      I18n.default_locale = :en
    end
  end
end
