require 'English'

rails_root = '/opt/homs'

working_directory rails_root
worker_processes(ENV.fetch('HOMS_UNICORN_WORKERS', 8).to_i)
timeout(ENV.fetch('HOMS_UNICORN_TIMEOUT', 30).to_i)

memory_limit = ENV.fetch('HOMS_UNICORN_MEMORY_LIMIT_MB', 450).to_i

listen '0.0.0.0:3000', backlog: 2048
pid '/tmp/unicorn.pid'

preload_app true

module UnicornMonitor
  attr_reader :memory_limit

  def process_client(*)
    @monitor_counter += 1
    start = Time.now.to_i
    super.tap do
      finish = Time.now.to_i

      if finish - start > 3 || (@monitor_counter % 20).zero?
        check_memory_consumption
      end
    end
  end

  def check_memory_consumption
    mem_size = current_memory_consumption
    logger = Rails.logger
    if mem_size > memory_limit
      ::Process.kill('QUIT', $PROCESS_ID)
      logger.info('Current memory consumption: %s mb. Reloading' % (mem_size.to_f / 1.megabyte).round(2))
    elsif logger.debug?
      logger.debug('Current memory consumption: %s mb' % (mem_size.to_f / 1.megabyte).round(2))
    end
  end

  def init_monitor(memory_limit)
    @memory_limit = memory_limit
    @monitor_counter = 0
  end

  def current_memory_consumption
    line = `#{memory_command}`
    parts = line.split
    parts[1].to_i.kilobytes
  end

  def memory_command
    @memory_command ||= "ps -e -www -o pid,rss,command | grep '[u]nicorn_rails worker' | grep #{$PROCESS_ID}"
  end
end

before_fork do |_server, _worker|
  ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, _worker|
  ActiveRecord::Base.establish_connection

  server.extend(UnicornMonitor).init_monitor(memory_limit)
end
