require 'rubygems'
require 'bundler'
require 'tempfile'
Bundler.setup
Bundler.require

# Small patch because Tilt expects files to respond to #to_str
class Tempfile
  def to_str
    path
  end
end

require File.expand_path(__FILE__, '../lib/hamlbars.rb')

RSpec.configure do |config|
  config.debug = false
  config.color_enabled = true
  config.formatter = 'd'
end
