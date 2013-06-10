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
  s.add_dependency 'sprockets'
  s.add_dependency 'tilt'
  s.add_dependency 'execjs', [">= 1.2"]
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', [">= 2.10.0"]
  s.add_development_dependency 'activesupport'
  
  s.files         = %w(README.md History.md MIT-LICENSE) + Dir["lib/**/*"]

  s.require_paths = ['lib']

  s.post_install_message = <<-EOM
  DEPRECATION WARNING: Hamlbars 2.0 removes asset compilation!

  Template compilation in Hamlbars was a major source of confusion and bugs
  since roughly half of its users are using Handlebars.js in their apps and
  the other half are using Handlebars as part of Ember.js.

  Hamlbars now simply outputs the rendered HTML marked up with Handlebars
  sections.  It is up to you to choose the Handlebars compiler that works
  for you.

  If you're using Ember.js I would suggest adding ember-rails to your
  Gemfile.

  If you're using Handlebars.js then I would suggest adding handlebars_assets
  to your Gemfile.

  For both of the above gems you may need to rename your templates to
  `mytemplate.js.hbs.hamlbars` in order for the output of Hamlbars to be sent
  into the correct compiler.

  Thanks for using Hamlbars. You're awesome.
  @jamesotron
  EOM
end

