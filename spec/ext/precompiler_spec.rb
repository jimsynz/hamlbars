require 'spec_helper'

describe Hamlbars::Ext::Precompiler do

  after(:all) do
    template_file.unlink
  end

  let(:template_file) { Tempfile.new 'hamlbars_template' }

  before :each do
    template_file.rewind
    Hamlbars::Template.enable_precompiler! 
    Hamlbars::Template.disable_closures!
  end

  after :each do
    template_file.flush
    Hamlbars::Template.disable_precompiler! 
    Hamlbars::Template.enable_closures!
  end

  it "should compile the template to JavaScript" do
    template_file.write("")
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.template(function anonymous(Handlebars,depth0,helpers,partials,data) {\nhelpers = helpers || Handlebars.helpers;\n  var self=this;\n\n\n  return \"(\\\"\\\");\";\n})\n"
  end
  
end
