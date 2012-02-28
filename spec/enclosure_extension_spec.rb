require 'spec_helper'

describe Hamlbars::EnclosureExtension do

  before(:all) do
    Hamlbars::Template.enable_enclosures! 
  end

  after(:all) do
    Hamlbars::Template.disable_enclosures! 
    template_file.unlink
  end

  let(:template_file) { Tempfile.new 'hamlbars_template' }

  before :each do
    template_file.rewind
  end

  after :each do
    template_file.flush
  end

  it "should wrap output in a closure" do
    template_file.write("")
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "function() { Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"\");\n }()"
  end

end
