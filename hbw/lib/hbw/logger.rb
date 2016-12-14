module HBW
  module Logger
    def logger
      Yell.new do |l|
        if Rails.env.production?
          l.adapter :datefile, logs_config.fetch(:production).fetch(:hbw_log), :level => Yell.level.lte(:warn)
          l.adapter :datefile, logs_config.fetch(:production).fetch(:hbw_error_log), :level => Yell.level.gte(:error)
        else
          l.adapter :datefile, logs_config.fetch(:development).fetch(:hbw_log)
        end
      end
    end

    def logs_config
      Homs::Application.config.app.fetch(:logs)
    end
  end
end
