module DatetimeFormat
  RUBY_TIME_FORMAT_MATCHES = [
    %w[%m MM],
    %w[%b MMM],
    %w[%B MMMM],
    %w[%j DDD],
    %w[%d dd],
    %w[%a EEE],
    %w[%A EEEE],
    %w[%Y yyyy],
    %w[%y yy],
    %w[%p aaa],
    %w[%P aaa],
    %w[%I hh],
    %w[%H HH],
    %w[%M mm],
    %w[%S ss]
  ].freeze

  def datetime_format
    Rails.application.config.app.locale.fetch(:datetime_format)
  end

  def date_format
    Rails.application.config.app.locale.fetch(:date_format)
  end

  def js_datetime_format
    to_date_fns_format(datetime_format)
  end

  def to_date_fns_format(ruby_format)
    RUBY_TIME_FORMAT_MATCHES.inject(ruby_format) do |format, (key, value)|
      format.gsub(key, value)
    end
  end
end
