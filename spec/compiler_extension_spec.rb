require 'spec_helper'

describe Haml::Compiler do

  it "should include Hamlbars::CompilerExtension" do
    Haml::Compiler.ancestors.should include(Hamlbars::CompilerExtension)
  end

  it "should define ::build_attributes_with_bindings" do
    Haml::Compiler.respond_to?(:build_attributes_with_bindings).should be_true
  end

  it "should define ::build_attributes_without_bindings" do
    Haml::Compiler.respond_to?(:build_attributes_without_bindings).should be_true
  end

  it "should alias ::build_attributes to ::build_attributes_with_bindings" do
    Haml::Compiler.method(:build_attributes).should eq(Haml::Compiler.method(:build_attributes_with_bindings))
  end

end
