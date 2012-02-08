module Hamlbars
  module CompilerExtension
  end
end

module Haml
  module Compiler
    class << self
      # Overload build_attributes in Haml::Compiler to allow
      # for the creation of handlebars bound attributes by
      # adding :bind hash to the tag attributes.
      def build_attributes_with_handlebars_attributes (is_html, attr_wrapper, escape_attrs, attributes={})
        attributes[:bind] = attributes.delete('bind') if attributes['bind']
        attributes[:event] = attributes.delete('event') if attributes['event']
        attributes[:events] = attributes.delete('events') if attributes['events']
        attributes[:events] ||= []
        attributes[:events] << attributes.delete(:event) if attributes[:event]

        handlebars_rendered_attributes = []
        handlebars_rendered_attributes << handlebars_attributes('bindAttr', is_html, escape_attrs, attributes.delete(:bind)) if attributes[:bind]
        attributes[:events].each do |event|
          on = event.delete('on') || event.delete(:on) || 'click'
          handlebars_rendered_attributes << handlebars_attributes("action \"#{on}\"", is_html, escape_attrs, event)
        end
        attributes.delete(:events)

        (handlebars_rendered_attributes * '') + 
          build_attributes_without_handlebars_attributes(is_html, attr_wrapper, escape_attrs, attributes)
      end
      alias build_attributes_without_handlebars_attributes build_attributes
      alias build_attributes build_attributes_with_handlebars_attributes 

      private

      def handlebars_attributes(helper, is_html, escape_attrs, attributes)
        " {{#{helper}#{build_attributes_without_handlebars_attributes(is_html, '"', escape_attrs, attributes)}}}"
      end
    end
  end
end
