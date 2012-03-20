require 'spec_helper'

describe Hamlbars::Ext::Closure do

  after(:all) do
    template_file.unlink
  end

  let(:template_file) { Tempfile.new 'hamlbars_template' }

  before :each do
    template_file.rewind
    Hamlbars::Template.enable_closures! 
  end

  after :each do
    template_file.flush
    Hamlbars::Template.disable_closures! 
  end

  it "should wrap output in a closure" do
    template_file.write("")
    template_file.rewind
    puts Hamlbars::Template.closures_enabled?
    template = Hamlbars::Template.new(template_file)
    template.render.should == "function() { Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"\");\n }()"
  end

end
