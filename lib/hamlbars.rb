require 'haml'
require 'sprockets'

module Hamlbars

  if defined? Rails
    class Engine < Rails::Engine
    end
  end

  ROOT = File.expand_path(File.dirname(__FILE__))

  autoload :CompilerExtension,    File.join(ROOT, 'hamlbars', 'compiler_extension')
  autoload :Template,             File.join(ROOT, 'hamlbars', 'template')
  autoload :RailsHelperExtension, File.join(ROOT, 'hamlbars', 'rails_helper_extension')
  autoload :EnclosureExtension,   File.join(ROOT, 'hamlbars', 'enclosure_extension')
  autoload :Template,             File.join(ROOT, 'hamlbars', 'template')

  Haml::Compiler.send(:include, CompilerExtension)

  if defined? Sprockets
    Sprockets.register_engine '.hamlbars', Template
    Sprockets.register_engine '.hbs', Template
  end

end
