Rails.application.config.to_prepare do
  HBW::Sources.load(YAML.load_file('config/sources.yml')['sources'])
  HBW::Widget.config = HBW::Config.load(%w(config/hbw.default.yml
                                           config/hbw.yml))['hbw']
end
