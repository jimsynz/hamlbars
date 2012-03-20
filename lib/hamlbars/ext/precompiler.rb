require 'execjs'

module Hamlbars
  module Ext
    module Precompiler

      def self.included(base)
        base.extend ClassMethods
      end

      # Takes the rendered template and compiles it using the Handlebars
      # compiler via ExecJS.
      def evaluate_with_precompiler(scope, locals, &block)
        if self.class.precompiler_enabled? 
          precompile { evaluate_without_precompiler(scope,locals,&block) }
        else
          evaluate_without_precompiler(scope,locals,&block)
        end
      end

      private

      def precompile
        str = yield
        str.gsub(Regexp.new("(#{Hamlbars::Template.template_compiler})\((.+)\)")) do |match|
          # No named groups. WAT!
          compiler = $1
          template = $2
          if compiler =~ /\.compile$/
            "#{compiler.gsub(/\.compile$/, '.template')}(#{runtime.call('Hamlbars.precompile', template)})"
          else
            # Unable to precompile.
            match
          end
        end
      end

      def runtime
        Thread.current[:hamlbars_js_runtime] ||= ExecJS.compile(js)
      end

      def js
        [ 'handlebars.js', 'precompiler.js' ].map do |name|
          File.read(File.expand_path("../../../../vendor/javascripts/#{name}", __FILE__))
        end.join("\n")
      end

      module ClassMethods

        # Enables use of the Handlebars compiler when rendering
        # templates.
        def enable_precompiler!
          @precompiler_enabled = true
          unless public_method_defined? :evaluate_without_precompiler
            alias_method :evaluate_without_precompiler, :evaluate
            alias_method :evaluate, :evaluate_with_precompiler
          end
        end

        def precompiler_enabled?
          !!@precompiler_enabled
        end

        def disable_precompiler!
          @precompiler_enabled = false
        end
      end

    end
  end
end
