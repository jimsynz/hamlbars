# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hamlbars/version"

Gem::Specification.new do |s|
  s.name          = "hamlbars"
  s.version       = Hamlbars::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['James Harton']
  s.email         = ['james@sociable.co.nz']
  s.homepage      = 'https://github.com/jamesotron/hamlbars'
  s.summary       = 'Extensions to HAML to allow creation of handlebars expressions.'
  s.add_dependency 'haml'
  s.add_dependency 'sprockets'
  s.add_dependency 'tilt'
  s.add_development_dependency 'rspec'
  
  s.files         = %w(README.md) + Dir["lib/**/*"]

  s.require_paths = ['lib']
end

