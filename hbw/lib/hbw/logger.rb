module HBW
  module Logger
    def logger
      Rails.logger
    end

    def logs_config
      Homs::Application.config.app.fetch(:logs)
    end
  end
end
