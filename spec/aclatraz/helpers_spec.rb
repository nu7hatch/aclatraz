require 'spec_helper'

describe "Aclatraz helpers" do 
  include Aclatraz::Helpers
  
  it "#camelize should return a camel cased word" do 
    camelize("foo_bar_bla").should == "FooBarBla"
    camelize("foo").should == "Foo"
  end
end
