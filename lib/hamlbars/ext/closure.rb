module Hamlbars
  module Ext
    module Closure

      def self.included(base)
        base.extend ClassMethods
      end
      
      def evaluate_with_closure(scope, locals, &block)
        self.class.closures_enabled? ? enclosify { evaluate_without_closure(scope,locals,&block) } : evaluate_without_closure(scope,locals,&block)
      end

      private

      def enclosify
        "(function() { #{yield} }).call(this)"
      end

      module ClassMethods
        def enable_closures!
          @enable_closures = true
          unless public_method_defined? :evaluate_without_closure
            alias_method :evaluate_without_closure, :evaluate
            alias_method :evaluate, :evaluate_with_closure
          end
        end

        def closures_enabled?
          !!@enable_closures
        end

        def disable_closures!
          @enable_closures = false
        end
      end

    end
  end
end
