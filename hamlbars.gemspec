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
  s.summary       = 'Extensions to Haml to allow creation of handlebars expressions.'
  s.description   = 'Hamlbars allows you to write handlebars templates using the familiar Haml syntax.'
  s.add_dependency 'haml'
  s.add_dependency 'sprockets', '>= 2.0'
  s.add_dependency 'tilt'
  s.add_dependency 'execjs', [">= 1.2"]
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', ["~> 3.0"]
  s.add_development_dependency 'activesupport'

  s.files         = %w(README.md History.md MIT-LICENSE) + Dir["lib/**/*"] + Dir["vendor/**/*"]

  s.require_paths = ['lib']
end

