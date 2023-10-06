LOG_LINE_PATTERN = '%s %s|%s|'.freeze
CEF_VERSION = 'CEF:0'.freeze
VENDOR_NAME = 'Hydra Billing'.freeze
APP_NAME = 'HOMS'.freeze

EVENTS = {
  logout:       {
    severity: 3,
    class:    :logout,
    name:     'System logout',
    message:  'Successful logout'
  },
  login:        {
    severity: 6,
    class:    :login,
    name:     'System login',
    message:  'Successful login'
  },
  failed_login: {
    severity: 8,
    class:    :login,
    name:     'System login',
    message:  'Failed login attempt'
  },
  start:        {
    severity: 9,
    class:    :start,
    name:     'Application start',
    message:  'Application has been started'
  },
  stop:         {
    severity: 9,
    class:    :stop,
    name:     'Application stop',
    message:  'Application has been stopped'
  }
}.freeze

class CEFLogger
  attr_reader :enabled

  def initialize(enabled: false)
    @enabled = enabled
  end

  def log_event(event_name, **)
    return unless @enabled

    time  = Time.now
    event = EVENTS[event_name]

    print_line(time, event, **)
  end

  def log_user_event(event_name, user, headers)
    log_event(
      event_name,
      source_address:      headers['Source-Address'],
      destination_address: headers['Destination-Address'],
      source_host_name:    headers['Source-Host-Name'],
      source_user_id:      user[:id],
      source_user_name:    user[:email]
    )
  end

  private

  def print_line(time, event, **)
    puts LOG_LINE_PATTERN % [
      time.iso8601,
      build_main_part(event),
      build_extension_part(event, time.to_i, **)
    ]
  end

  def build_main_part(event)
    [
      CEF_VERSION,
      VENDOR_NAME,
      APP_NAME,
      HOMS::Application::VERSION,
      event[:class],
      event[:name],
      event[:severity]
    ].join('|')
  end

  def build_extension_part(event, timestamp, **options)
    {
      src:   options[:source_address],
      dst:   options[:destination_address],
      shost: options[:source_host_name],
      suid:  options[:source_user_id],
      suser: options[:source_user_name],
      msg:   event[:message],
      end:   timestamp
    }.map { |k, v| "#{k}=#{v}" }.join(' ')
  end
end
