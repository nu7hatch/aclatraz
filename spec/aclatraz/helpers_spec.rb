require 'spec_helper'

describe "Aclatraz helpers" do 
  include Aclatraz::Helpers
  
  it "#camelize should return a camel cased word" do 
    camelize("foo_bar_bla").should == "FooBarBla"
    camelize("foo").should == "Foo"
  end
  
  it "#pack should return packed permission" do 
    pack(10).should == "10"
    
    class StubTarget; def id; 15; end; end
    pack(10, StubTarget).should == "10/StubTarget" 

    target = StubTarget.new
    pack(10, target).should == "10/StubTarget/15"
  end
end
