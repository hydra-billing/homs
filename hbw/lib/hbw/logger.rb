HBW_FORMAT = ' [HBW] %s'.freeze
HBW_DURATION = 'DURATION'.freeze

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
    logger.formatter = if Rails.env.production?
                         HBWFormatterProduction.new
                       else
                         HBWFormatter.new
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

    def log_duration(level, start)
      tagged_logger = ActiveSupport::TaggedLogging.new(logger)

      tagged_logger.tagged(HBW_DURATION) do
        tagged_logger.public_send(level) do
          format('Completed %s "%s" in %0.2fms',
                 request.method,
                 request.original_fullpath,
                 (Time.now.to_f - start) * 1000)
        end
      end
    end
  end
end
