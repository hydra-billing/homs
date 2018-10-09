HOMS_FORMAT = '[HOMS] %s'

class HomsFormatterProduction < Logger::Formatter
  include ActiveSupport::TaggedLogging::Formatter

  def call(severity, time, program_name, message)
    HOMS_FORMAT % super(severity, time, program_name, message.dup.gsub('\n', ''))
  end
end

class HomsFormatter < Logger::Formatter
  include ActiveSupport::TaggedLogging::Formatter

  def call(severity, time, program_name, message)
    HOMS_FORMAT % super(severity, time, program_name, message)
  end
end

module HomsLogger
  include ActiveSupport::TaggedLogging

  def self.new(logger)
    if Rails.env.production?
      logger.formatter ||= HomsFormatterProduction.new
    else
      logger.formatter ||= HomsFormatter.new
    end

    logger.extend(self)
  end
end
