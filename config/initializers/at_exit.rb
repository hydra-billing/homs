at_exit do
  HOMS.container[:cef_logger].log_event(:stop)
end
