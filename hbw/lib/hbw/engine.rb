require_relative 'container'

module HBW
  class Engine < ::Rails::Engine
    isolate_namespace HBW
  end
end

require 'hbw/config'
require 'hbw/logger'
