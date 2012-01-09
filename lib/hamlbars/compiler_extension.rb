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
      def build_attributes_with_bindings (is_html, attr_wrapper, escape_attrs, attributes={})
        attributes[:bind] = attributes.delete('bind') if attributes['bind']
        bindings = if attributes[:bind].is_a? Hash
                     " {{bindAttr#{build_attributes_without_bindings(is_html, attr_wrapper, escape_attrs, attributes.delete(:bind))}}}"
                   else 
                   ''
                   end
        ' ' + build_attributes_without_bindings(is_html, attr_wrapper, escape_attrs, attributes) + bindings
      end
      alias build_attributes_without_bindings build_attributes
      alias build_attributes build_attributes_with_bindings 
    end
  end
end
