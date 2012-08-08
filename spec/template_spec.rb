require 'spec_helper.rb'
require 'active_support'
require 'active_support/core_ext/string/output_safety'

describe Hamlbars::Template do

  let(:template_file) { Tempfile.new 'hamlbars_template' }

  before :each do
    template_file.rewind
  end

  after :each do
    template_file.flush
  end

  before :all do
    Hamlbars::Template.disable_closures!
  end

  after :all do
    Hamlbars::Template.enable_closures!
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

  it "should not close else contents" do
    template_file.write <<EOF
= hb 'if a_thing_is_true' do
  Hello
  = hb 'else' do
    Goodbye
EOF
    template_file.rewind
    template = Hamlbars::Template.new(template_file)
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"{{#if a_thing_is_true}}Hello\\n{{#else}}Goodbye{{/if}}\");\n"

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

  before :all do
    Hamlbars::Template.disable_closures!
  end

  after :all do
    template_file.unlink
    Hamlbars::Template.enable_closures!
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
  before :all do
    Hamlbars::Template.disable_closures!
  end

  after :all do
    Hamlbars::Template.enable_closures!
  end

  it "should replace everything but letters, numbers and slashes with _" do
    Hamlbars::Template.path_translator("asdf1234,%*/.").should == "asdf1234___/_"
  end
end

describe Hamlbars::Template, '::template_destination' do

  let(:template_file) { Tempfile.new 'hamlbars_template' }
  let(:template) { Hamlbars::Template.new(template_file) }

  before do
    Hamlbars::Template.disable_closures!
    @original_template_destination = Hamlbars::Template.template_destination
    Hamlbars::Template.template_destination='HamlbarsTestTemplates'
    template_file.write('')
    template_file.rewind
  end

  after do
    Hamlbars::Template.enable_closures!
    Hamlbars::Template.template_destination=@origina_template_destination
    template_file.flush
  end

  it "should reflect changed template destination" do
    template.render.should == "HamlbarsTestTemplates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = Handlebars.compile(\"\");\n"
  end

end

describe Hamlbars::Template, '::template_partial_method' do

  let(:template_file) { Tempfile.new '_hamlbars_template' }
  let(:template) { Hamlbars::Template.new(template_file) }

  before do
    Hamlbars::Template.disable_closures!
    @original_template_partial_method = Hamlbars::Template.template_partial_method
    Hamlbars::Template.template_partial_method='HamlbarsTestPartial'
    template_file.write('')
    template_file.rewind
  end

  after do
    Hamlbars::Template.enable_closures!
    Hamlbars::Template.template_partial_method=@original_template_partial_method
    template_file.flush
  end

  it "should reflect changed template partial method name" do
    partial_location = Hamlbars::Template.path_translator(File.basename(template_file.path))[1..-1]
    template.render.should == "HamlbarsTestPartial('#{partial_location}', '');\n"
  end

end

describe Hamlbars::Template, '::template_compiler' do

  let(:template_file) { Tempfile.new 'hamlbars_template' }
  let(:template) { Hamlbars::Template.new(template_file) }

  before do
    Hamlbars::Template.disable_closures!
    @original_template_compiler = Hamlbars::Template.template_compiler
    Hamlbars::Template.template_compiler='HamlbarsTestCompiler'
    template_file.write('')
    template_file.rewind
  end

  after do
    Hamlbars::Template.enable_closures!
    Hamlbars::Template.template_compiler=@origina_template_compiler
    template_file.flush
  end

  it "should reflect changed template compiler" do
    template.render.should == "Handlebars.templates[\"#{Hamlbars::Template.path_translator(File.basename(template_file.path))}\"] = HamlbarsTestCompiler(\"\");\n"
  end

end

describe Hamlbars::Template, '::render_templates_for' do

  describe :handlebars do

    subject { Hamlbars::Template } 
    before { subject.render_templates_for :handlebars }

    it "::template_destination should equal 'Handlebars.templates'" do
      subject.template_destination.should == 'Handlebars.templates'
    end

    it "::template_compiler should equal 'Handlebars.compile'" do
      subject.template_compiler.should == 'Handlebars.compile'
    end

    it "::template_partial_method should equal 'Handlebars.registerPartial'" do
      subject.template_partial_method.should == 'Handlebars.registerPartial'
    end

  end

  describe :ember do

    subject { Hamlbars::Template } 
    before { subject.render_templates_for :ember }
    after { subject.render_templates_for :handlebars }

    it "::template_destination should equal 'Ember.TEMPLATES'" do
      subject.template_destination.should == 'Ember.TEMPLATES'
    end

    it "::template_compiler should equal 'Ember.Handlebars.compile'" do
      subject.template_compiler.should == 'Ember.Handlebars.compile'
    end

    it "::template_partial_method should equal 'Ember.Handlebars.registerPartial'" do
      subject.template_partial_method.should == 'Ember.Handlebars.registerPartial'
    end

  end


end
