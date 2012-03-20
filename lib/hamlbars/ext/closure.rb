module Hamlbars
  module Ext
    module Closure

      def self.included(base)
        base.extend ClassMethods
      end

      def evaluate(*)
        enclosify super
      end

      private

      def enclosify(data)
        if self.class.closures_enabled?
          "function() { #{data} }()"
        else
          data
        end
      end

      module ClassMethods
        def enable_closures!
          @enable_closures = true
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
