app_root = '/var/www/homs'
rails_root = "#{app_root}/current"

working_directory rails_root
worker_processes 4
preload_app true
timeout 30

listen "#{app_root}/shared/tmp/sockets/unicorn.sock", backlog: 2048
pid "#{app_root}/shared/tmp/pids/unicorn.pid"
stderr_path "#{app_root}/shared/log/unicorn.log"
stdout_path "#{app_root}/shared/log/unicorn.log"

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

before_fork do |server, _worker|
  ActiveRecord::Base.connection.disconnect!

  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.

  old_pid = "#{app_root}/shared/pids/unicorn.pid.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
      # rubocop:disable Lint/HandleExceptions
    rescue Errno::ENOENT, Errno::ESRCH
      # rubocop:enable Lint/HandleExceptions
      # someone else did our job for us
    end
  end
end

after_fork do |_server, _worker|
  ActiveRecord::Base.establish_connection
end
