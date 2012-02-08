require 'spec_helper'

describe "Sprockets" do
  it "should register .hamlbars extension" do
    Sprockets.engines('.hamlbars').should be(Hamlbars::Template)
  end

  it "should register .hbs extension" do
    Sprockets.engines('.hbs').should be(Hamlbars::Template)
  end
end
