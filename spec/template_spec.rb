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
    template_file.unlink
  end

  def to_handlebars(s)
    template_file.write(s)
    template_file.rewind
    handlebars = Hamlbars::Template.new(template_file, :format => :xhtml).render
    handlebars.chomp
  end

  it "should render compiler preamble" do
    expect(to_handlebars('')).to eq('')
  end

  it "should bind element attributes" do
    expect(to_handlebars('%img{ :bind => { :src => "logoUri" }, :alt => "Logo" }')).to eq(
      "<img {{bind-attr src=\"logoUri\"}} alt=\'Logo\' />"
    )
  end

  it "should render action attributes" do
    expect(to_handlebars('%a{ :_action => \'edit article on="click"\' } Edit')).to eq(
      '<a {{action "edit" article on="click"}}>Edit</a>'
    )
  end

  it "should render in-tag expressions" do
    expect(to_handlebars('%div{:hb => \'testExpression\'}')).to eq(
      '<div {{testExpression}}></div>'
    )
  end

  it 'should render multiple in-tag expressions' do
    expect(to_handlebars('%div{:hb => [\'firstTestExpression\', \'secondTestExpression withArgument\']}')).to eq(
      '<div {{firstTestExpression}} {{secondTestExpression withArgument}}></div>'
    )
  end

  it "should render expressions" do
    expect(to_handlebars('= hb "hello"')).to eq(
      "{{hello}}"
    )
  end

  it "should render block expressions" do
    expect(to_handlebars("= hb 'hello' do\n  world.")).to eq(
      "{{#hello}}\n  world.\n{{/hello}}"
    )
  end

  it "should keep newlines on block expressions" do
    handlebars = to_handlebars <<EOF
= hb 'if something' do
  %div
    One
    %div two
EOF
    expected = <<EOF
{{#if something}}
  <div>
    One
    <div>two</div>
  </div>
{{/if}}
EOF

    expect(handlebars).to eq(expected.strip)
  end

  it "should render expression options" do
    expect(to_handlebars('= hb "hello",:whom => "world"')).to eq(
      "{{hello whom=\"world\"}}"
    )
  end

  it "should render tripple-stash expressions" do
    expect(to_handlebars('= hb! "hello"')).to eq(
      "{{{hello}}}"
    )
  end

  it "should render tripple-stash block expressions" do
    expect(to_handlebars("= hb! 'hello' do\n  world.")).to eq(
      "{{{#hello}}}\n  world.\n{{{/hello}}}"
    )
  end

  it "should render tripple-stash expression options" do
    expect(to_handlebars('= hb! "hello",:whom => "world"')).to eq(
      "{{{hello whom=\"world\"}}}"
    )
  end

  it "should not escape block contents" do
    handlebars = to_handlebars <<EOF
= hb 'if a_thing_is_true' do
  = hb 'hello'
  %a{:bind => {:href => 'aController'}}
EOF
    expect(handlebars).to eq("{{#if a_thing_is_true}}\n  {{hello}}\n<a {{bind-attr href=\"aController\"}}></a>\n{{/if}}")
  end

  it "should not mark expressions as html_safe when XSS protection is disabled" do
    Haml::Util.module_eval do
      def rails_xss_safe?
        false
      end
    end
    Hamlbars::Template
    helpers = Class.new { include Haml::Helpers }.new
    helpers.hb expect('some_expression').not_to be_a(ActiveSupport::SafeBuffer)
  end

  it "should not mark expressions as html_safe when XSS protection is disabled" do
    Haml::Util.module_eval do
      def rails_xss_safe?
        true
      end
    end
    Hamlbars::Template
    helpers = Class.new { include Haml::Helpers }.new
    helpers.hb expect('some_expression').not_to be_a(ActiveSupport::SafeBuffer)
  end

end
