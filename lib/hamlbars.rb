require 'haml'
require 'sprockets'

module Hamlbars

  if defined? Rails
    class Engine < Rails::Engine
    end
  end

  ROOT = File.expand_path(File.dirname(__FILE__))

  autoload :Ext,      File.join(ROOT, 'hamlbars', 'ext')
  autoload :Template, File.join(ROOT, 'hamlbars', 'template')

  Haml::Compiler.send(:include, Ext::Compiler)

  if defined? Sprockets
    Sprockets.register_engine '.hamlbars', Template
    Sprockets.register_engine '.hbs', Template
  end

end
