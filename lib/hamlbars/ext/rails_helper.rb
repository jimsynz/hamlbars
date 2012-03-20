module Hamlbars
  module Ext
    module RailsHelper

      def self.included(base)
        base.extend ClassMethods
      end

      def evaluate(scope,locals,&block)
        scope = scope.dup

        scope.class.send(:include, ActionView::Helpers) if defined?(::ActionView)
        if defined?(::Rails)
          scope.class.send(:include, Rails.application.helpers)
          scope.class.send(:include, Rails.application.routes.url_helpers)
          scope.default_url_options = Rails.application.config.action_controller.default_url_options || {}
        end
        super(scope, locals, &block)
      end

      module ClassMethods
        def enable_rails_helpers!
          (Rails.env == 'development' ? Logger.new(STDOUT) : Rails.logger).warn "WARNING (hamlbars): Enabling helpers in assets can have unintended consequences and violates separation of concerns. You have been warned."
          @enable_rails_helpers = true
        end

        def rails_helpers_enabled?
          !!@enable_rails_helpers
        end

        def disable_rails_helpers!
          @enable_rails_helpers = false
        end
      end

    end
  end
end
