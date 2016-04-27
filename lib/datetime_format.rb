module DatetimeFormat
  def datetime_format
    I18n.t('time.formats.datetime') || Rails.application.config.app.locale.fetch(:datetime_format)
  end
end
