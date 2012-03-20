require 'spec_helper'

describe Haml::Compiler do

  it "should include Hamlbars::CompilerExtension" do
    Haml::Compiler.ancestors.should include(Hamlbars::Ext::Compiler)
  end

  it "should define ::build_attributes_with_handlebars_attributes" do
    Haml::Compiler.respond_to?(:build_attributes_with_handlebars_attributes).should be_true
  end

  it "should define ::build_attributes_without_handlebars_attributes" do
    Haml::Compiler.respond_to?(:build_attributes_without_handlebars_attributes).should be_true
  end

  it "should alias ::build_attributes to ::build_attributes_with_handlebars_attributes" do
    Haml::Compiler.method(:build_attributes).should eq(Haml::Compiler.method(:build_attributes_with_handlebars_attributes))
  end

end
