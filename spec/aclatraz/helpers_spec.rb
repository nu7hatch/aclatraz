require File.dirname(__FILE__) + '/../spec_helper'

describe "Aclatraz helpers" do 
  include Aclatraz::Helpers
  
  it "#camelize should return a camel cased word" do 
    camelize("foo_bar_bla").should == "FooBarBla"
    camelize("foo").should == "Foo"
  end
  
  it "#suspect_id should properly resolve id of given object" do 
    suspect_id("1").should == "1"
    suspect_id(1).should == "1"
    suspect_id(StubSuspect.new).should == "10"
  end
  
  it "#unpack should properly split given string by /" do 
    unpack("foo/bar/10").should == %w[foo bar 10]
    unpack(nil).should == []
  end
  
  it "#pack should work properly" do 
    pack("admin").should == "admin"
    pack("admin", StubTarget).should == "admin/StubTarget"
    pack("admin", StubTarget.new).should == "admin/StubTarget/10"
  end
end
