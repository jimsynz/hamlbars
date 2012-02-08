require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require

require File.expand_path(__FILE__, '../lib/hamlbars.rb')

RSpec.configure do |config|
  config.debug = false
  config.color_enabled = true
  config.formatter = 'd'
end
