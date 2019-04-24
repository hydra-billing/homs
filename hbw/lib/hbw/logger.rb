HBW_FORMAT = ' [HBW] %s'

class HBWFormatterProduction < Logger::Formatter
  include ActiveSupport::TaggedLogging::Formatter

  def call(severity, time, program_name, message)
    HBW_FORMAT % super(severity, time, program_name, message.dup.gsub('\n', ''))
  end
end

class HBWFormatter < Logger::Formatter
  include ActiveSupport::TaggedLogging::Formatter

  def call(severity, time, program_name, message)
    HBW_FORMAT % super(severity, time, program_name, message)
  end
end

module HBWLogger
  include ActiveSupport::TaggedLogging

  def self.new(logger)
    if Rails.env.production?
      logger.formatter = HBWFormatterProduction.new
    else
      logger.formatter = HBWFormatter.new
    end

    logger.extend(self)
  end
end

module HBW
  module Logger
    def logger
      logger = HBWLogger.new(ActiveSupport::Logger.new(STDOUT))
      logger.level = ENV['LOG_LEVEL'] || 'info'
      logger
    end
  end
end
