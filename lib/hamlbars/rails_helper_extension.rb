module Hamlbars
  module RailsHelperExtension

    def self.included(base)
      base.extend ClassMethods
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

    module ClassMethods
      def enable_rails_helpers!
        (Rails.env == 'development' ? Logger.new(STDOUT) : Rails.logger).warn "WARNING (hamlbars): Enabling helpers in assets can have unintended consequences and violates separation of concerns. You have been warned."
        alias_method :evaluate_without_rails_helpers, :evaluate
        alias_method :evaluate, :evaluate_with_rails_helpers
      end

      def disable_rails_helpers!
        alias_method :evaluate_with_rails_helpers, :evaluate
        alias_method :evaluate, :evaluate_without_rails_helpers
      end
    end

  end
end
