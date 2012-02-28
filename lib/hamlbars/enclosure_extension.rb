module Hamlbars
  module EnclosureExtension

    def self.included(base)
      base.extend ClassMethods
    end

    def evaluate_with_enclosures(scope, locals, &block)
      enclosify(evaluate_without_enclosures(scope, locals, &block))
    end

    private

    def enclosify(data)
      "function() { #{data} }()"
    end

    module ClassMethods
      def enable_enclosures!
        alias_method :evaluate_without_enclosures, :evaluate
        alias_method :evaluate, :evaluate_with_enclosures
      end

      def disable_enclosures!
        alias_method :evaluate_with_enclosures, :evaluate
        alias_method :evaluate, :evaluate_without_enclosures
      end
    end

  end
end
