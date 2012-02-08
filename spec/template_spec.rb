require 'spec_helper.rb'
require 'tempfile'

  # Small patch because Tilt expects files to respond to #to_str
class Tempfile
  def to_str
    path
  end
end

describe Hamlbars::Template do

  let(:template_file) { Tempfile.new 'hamlbars_template' }

  before :each do
    template_file.rewind
  end

  after :each do
    template_file.flush
  end

  after :all do
    template_file.unlink
  end

  it "should bind element attributes" do
    template_file.write('%img{ :bind => { :src => "logoUri" }, :alt => "Logo" }')
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"<img {{bindAttr src=\\\"logoUri\\\"}} alt=\\'Logo\\' />\");\n"
  end

  it "should bind single event attribute" do
    template_file.write('%a{ :event => { :action => "edit" } } Edit')
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"<a {{action \\\"click\\\" action=\\\"edit\\\"}}>Edit</a>\");\n"
  end

  it "should bind multiple event attributes" do
    template_file.write('%a{ :events => [ { :action => "edit" }, { :on => "mouseover", :action => "showEditable" } ] } Edit')
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"<a {{action \\\"click\\\" action=\\\"edit\\\"}} {{action \\\"mouseover\\\" action=\\\"showEditable\\\"}}>Edit</a>\");\n"
  end

  it "should render expressions" do
    template_file.write('= hb "hello"')
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"{{hello}}\");\n"
  end

  it "should render block expressions" do
    template_file.write("= hb 'hello' do\n  world.")
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"{{#hello}}world.{{/hello}}\");\n"
  end

  it "should render expression options" do
    template_file.write('= hb "hello",:whom => "world"')
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"{{hello whom=\\\"world\\\"}}\");\n"
  end

  it "should render tripple-stash expressions" do
    template_file.write('= hb! "hello"')
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"{{{hello}}}\");\n"
  end

  it "should render tripple-stash block expressions" do
    template_file.write("= hb! 'hello' do\n  world.")
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"{{{#hello}}}world.{{{/hello}}}\");\n"
  end

  it "should render tripple-stash expression options" do
    template_file.write('= hb! "hello",:whom => "world"')
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"{{{hello whom=\\\"world\\\"}}}\");\n"
  end

end
