module Hamlbars
  module Ext
    module Compiler
      def self.handlebars_attributes(helper, attributes)
        rendered_attributes = [].tap { |r|attributes.each { |k,v| r << "#{k}=\"#{v}\"" } }.join(' ')
        " {{#{helper} #{rendered_attributes}}}"
      end

      def self.included(base)
        base.instance_eval do

          if Haml::VERSION >= "3.2"
            # Haml 3.2 introduces hyphenate_data_attrs
            def build_attributes_with_handlebars_attributes (is_html, attr_wrapper, escape_attrs, hyphenate_data_attrs, attributes={})
              handlebars_rendered_attributes = build_attributes_with_handlebars_attributes_base(is_html, attr_wrapper, escape_attrs, attributes)

              (handlebars_rendered_attributes * '') +
                build_attributes_without_handlebars_attributes(is_html, attr_wrapper, escape_attrs, hyphenate_data_attrs, attributes)
            end
          else
            def build_attributes_with_handlebars_attributes (is_html, attr_wrapper, escape_attrs, attributes={})
              handlebars_rendered_attributes = build_attributes_with_handlebars_attributes_base(is_html, attr_wrapper, escape_attrs, attributes)

              (handlebars_rendered_attributes * '') +
                build_attributes_without_handlebars_attributes(is_html, attr_wrapper, escape_attrs, attributes)
            end
          end

          # Overload build_attributes in Haml::Compiler to allow
          # for the creation of handlebars bound attributes by
          # adding :bind hash to the tag attributes.
          def build_attributes_with_handlebars_attributes_base(is_html, attr_wrapper, escape_attrs, attributes={})
            handlebars_rendered_attributes = []

            if bind = attributes.delete('bind')
              handlebars_rendered_attributes << Hamlbars::Ext::Compiler.handlebars_attributes('bind-attr', bind)
            end

            if hb = attributes.delete('hb')
              (hb.respond_to?(:each) ? hb : [hb]).each do |expression|
                handlebars_rendered_attributes << " {{#{expression}}}"
              end
            end

            # This could be generalized into /_.*/ catch-all syntax, if
            # necessary. https://github.com/jamesotron/hamlbars/pull/33
            if action = attributes.delete('_action')
              handlebars_rendered_attributes << " {{action #{action}}}"
            end

            handlebars_rendered_attributes
          end
          alias build_attributes_without_handlebars_attributes build_attributes
          alias build_attributes build_attributes_with_handlebars_attributes
        end
      end
    end
  end
end
