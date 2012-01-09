require 'haml'

module Hamlbars

  if defined? Rails
    class Engine < Rails::Engine
    end
  end

  ROOT = File.expand_path(File.dirname(__FILE__))

  autoload :CompilerExtension, File.join(ROOT, 'hamlbars', 'compiler_extension')

  Haml::Compiler.send(:include, CompilerExtension)

  if defined? Sprockets
    Sprockets.register_engine '.hamlbars', HamlbarsTemplate
    Sprockets.register_engine '.hbs', HamlbarsTemplate
  end

end
