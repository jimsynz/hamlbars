require 'tilt/template'

module Hamlbars
  class Template < Tilt::Template

    JS_ESCAPE_MAP = {
      "\r\n"  => '\n',
      "\n"    => '\n',
      "\r"    => '\n',
      '"'     => '\\"',
      "'"     => "\\'"
    }

    def self.path_translator(path)
      path.downcase.gsub(/[^a-z0-9]/, '_')
    end

    def self.template_destination
      @template_destination ||= 'Handlebars.templates'
    end

    def self.template_destination=(x)
      @template_destination = x
    end

    def self.template_compiler
      @template_compiler ||= 'Handlebars.compile'
    end

    def self.template_compiler=(x)
      @template_compiler = x
    end

    def self.template_partial_method
      @template_partial_method ||= 'Handlebars.registerPartial'
    end

    def self.template_partial_method=(x)
      @template_partial_method = x
    end

    self.default_mime_type = 'application/javascript'

    def self.engine_initialized?
      defined? ::Haml::Engine
    end

    if defined? ::Rails
      def self.enable_rails_helpers!
        (Rails.env == 'development' ? Logger.new(STDOUT) : Rails.logger).warn "WARNING (hamlbars): Enabling helpers in assets can have unintended consequences and violates separation of concerns. You have been warned."
        alias_method :evaluate_without_rails_helpers, :evaluate
        alias_method :evaluate, :evaluate_with_rails_helpers
      end
    end

    def initialize_engine
      require_template_library 'haml'
    end

    def prepare
      options = @options.merge(:filename => eval_file, :line => line)
      @engine = ::Haml::Engine.new(data, options)
    end

    def evaluate_with_rails_helpers(scope, locals, &block)
      scope = scope.dup

      scope.class.send(:include, ActionView::Helpers) if defined?(::ActionView)
      if defined?(::Rails)
        scope.class.send(:include, Rails.application.helpers)
        scope.class.send(:include, Rails.application.routes.url_helpers)
        scope.default_url_options = Rails.application.config.action_controller.default_url_options || {}
      end
      evaluate_without_rails_helpers(scope, locals, &block)
    end

    def evaluate(scope, locals, &block)
      template = if @engine.respond_to?(:precompiled_method_return_value, true)
                   super(scope, locals, &block)
                 else
                   @engine.render(scope, locals, &block)
                 end
      if basename =~ /^_/
        "#{self.class.template_partial_method}('#{name}', '#{template.strip.gsub(/(\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }}');\n"
      elsif scope.respond_to? :logical_path
        "#{self.class.template_destination}[\"#{self.class.path_translator(scope.logical_path)}\"] = #{self.class.template_compiler}(\"#{template.strip.gsub(/(\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }}\");\n"
      else
        "#{self.class.template_destination}[\"#{self.class.path_translator(basename)}\"] = #{self.class.template_compiler}(\"#{template.strip.gsub(/(\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }}\");\n"
      end
    end

    # Precompiled Haml source. Taken from the precompiled_with_ambles
    # method in Haml::Precompiler:
    # http://github.com/nex3/haml/blob/master/lib/haml/precompiler.rb#L111-126
    def precompiled_template(locals)
      @engine.precompiled
    end

    def precompiled_preamble(locals)
      local_assigns = super
      @engine.instance_eval do
        <<-RUBY
          begin
            extend Haml::Helpers
            _hamlout = @haml_buffer = Haml::Buffer.new(@haml_buffer, #{options_for_buffer.inspect})
            _erbout = _hamlout.buffer
            __in_erb_template = true
            _haml_locals = locals
        #{local_assigns}
        RUBY
      end
    end

    def precompiled_postamble(locals)
      @engine.instance_eval do
        <<-RUBY
        #{precompiled_method_return_value}
          ensure
            @haml_buffer = @haml_buffer.upper
          end
        RUBY
      end
    end
  end
end

module Haml
  module Helpers

    module HamlbarsExtensions
      # Used to create handlebars expressions within HAML,
      # if you pass a block then it will create a Handlebars
      # block helper (ie "{{#expression}}..{{/expression}}" 
      # otherwise it will create an expression 
      # (ie "{{expression}}").
      def handlebars(expression, options={}, &block)
        express(['{{','}}'],expression,options,&block)
      end
      alias hb handlebars

      # The same as #handlebars except that it outputs "triple-stash"
      # expressions, which means that Handlebars won't escape the output.
      def handlebars!(expression, options={}, &block)
        express(['{{{','}}}'],expression,options,&block)
      end
      alias hb! handlebars!

    private

      def make(expression, options)
        if options.any?
          expression << " " << options.map {|key, value| "#{key}=\"#{value}\"" }.join(' ')
        else
          expression
        end
      end

      def express(demarcation,expression,options={},&block)
        if block.respond_to? :call
          content = capture_haml(&block)
          "#{demarcation.first}##{make(expression, options)}#{demarcation.last}#{content.strip}#{demarcation.first}/#{expression.split(' ').first}#{demarcation.last}"
        else
          "#{demarcation.first}#{make(expression, options)}#{demarcation.last}"
        end
      end

    end

    include HamlbarsExtensions
  end
end

