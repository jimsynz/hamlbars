module Hamlbars
  module Ext
    autoload :Compiler,    File.expand_path('../ext/compiler.rb', __FILE__)
    autoload :Closure,     File.expand_path('../ext/closure.rb', __FILE__)
    autoload :RailsHelper, File.expand_path('../ext/rails_helper.rb', __FILE__)
  end
end
