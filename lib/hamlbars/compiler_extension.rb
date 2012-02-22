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
        handlebars_rendered_attributes << handlebars_attributes('bindAttr', attributes.delete(:bind)) if attributes[:bind]
        attributes[:events].each do |event|
          event[:on] = event.delete('on') || event.delete(:on) || 'click'
          action = event.delete('action') || event.delete(:action)
          handlebars_rendered_attributes << handlebars_attributes("action \"#{action}\"", event)
        end
        attributes.delete(:events)

        (handlebars_rendered_attributes * '') +
          build_attributes_without_handlebars_attributes(is_html, attr_wrapper, escape_attrs, attributes)
      end
      alias build_attributes_without_handlebars_attributes build_attributes
      alias build_attributes build_attributes_with_handlebars_attributes 

      private

      def handlebars_attributes(helper, attributes)
        rendered_attributes = [].tap { |r|attributes.each { |k,v| r << "#{k}=\"#{v}\"" } }.join(' ')
        " {{#{helper} #{rendered_attributes}}}"
      end
    end
  end
end
