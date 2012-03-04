require 'spec_helper.rb'
require 'tempfile'
require 'active_support'
require 'active_support/core_ext/string/output_safety'

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

  before :all do
    Hamlbars::Template.disable_enclosures!
  end

  after :all do
    Hamlbars::Template.enable_enclosures!
    template_file.unlink
  end

  it "should render compiler preamble" do
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"\");\n"
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
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"<a {{action \\\"edit\\\" on=\\\"click\\\"}}>Edit</a>\");\n"
  end

  it "should bind multiple event attributes" do
    template_file.write('%a{ :events => [ { :action => "edit" }, { :on => "mouseover", :action => "showEditable" } ] } Edit')
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"<a {{action \\\"edit\\\" on=\\\"click\\\"}} {{action \\\"showEditable\\\" on=\\\"mouseover\\\"}}>Edit</a>\");\n"
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

  it "should not escape block contents" do
    template_file.write <<EOF
= hb 'if a_thing_is_true' do
  = hb 'hello'
  %a{:bind => {:href => 'aController'}}
EOF
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"{{#if a_thing_is_true}}{{hello}}\\n<a {{bindAttr href=\\\"aController\\\"}}></a>{{/if}}\");\n"
  end

  it "should not mark expressions as html_safe when XSS protection is disabled" do
    Haml::Util.module_eval do
      def rails_xss_safe?
        false
      end
    end
    Hamlbars::Template
    helpers = Class.new { include Haml::Helpers }.new
    helpers.hb 'some_expression'.should_not be_a(ActiveSupport::SafeBuffer)
  end

  it "should not mark expressions as html_safe when XSS protection is disabled" do
    Haml::Util.module_eval do
      def rails_xss_safe?
        true
      end
    end
    Hamlbars::Template
    helpers = Class.new { include Haml::Helpers }.new
    helpers.hb 'some_expression'.should_not be_a(ActiveSupport::SafeBuffer)
  end

end

describe Hamlbars::Template, "partials" do

  let(:template_file) { Tempfile.new '_hamlbars_template' }
  let(:template) { Hamlbars::Template.new(template_file) }

  before :each do
    template_file.rewind
  end

  after :each do
    template_file.flush
  end

  after :all do
    template_file.unlink
  end

  it "should render partial preamble" do
    basename = File.basename(template_file.path)
    partial_name = basename.gsub(/-/, '_')[1..-1]
    template.render.should == "Handlebars.registerPartial('#{partial_name}', \'\');\n"
  end

  describe "#partial_path_translator" do
    it "should replace everything but letters, numbers with _ and / with ." do
      template.partial_path_translator("asdf1234,%*/.").should == "asdf1234___._"
    end

    it "it should remove the underscore from the partial name" do
      template.partial_path_translator("shared/_partial").should == "shared.partial"
    end
  end
end

describe Hamlbars::Template, "#path_translator" do
  it "should replace everything but letters, numbers and slashes with _" do
    Hamlbars::Template.path_translator("asdf1234,%*/.").should == "asdf1234___/_"
  end
end
