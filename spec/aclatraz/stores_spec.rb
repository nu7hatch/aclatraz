require 'spec_helper'

STORE_SPECS = proc do
  it "should properly assign given roles to owner and check permissions" do
    subject.set("foo", owner)
    subject.check("foo", owner).should be_true
    
    subject.set("bar", owner, StubTarget)
    subject.check("bar", owner, StubTarget).should be_true
    
    subject.set("bla", owner, target)
    subject.check("bla", owner, target).should be_true
    
    subject.check("foo", owner, target).should be_false
    subject.check("foo", owner, StubTarget).should be_false
    subject.check("bar", owner).should be_false
  end
  
  it "should properly delete given permission" do
    subject.set("foo", owner)
    subject.set("bar", owner, StubTarget)
    subject.set("bla", owner, target)
    
    subject.delete("bar", owner)
    subject.delete("bar", owner, StubTarget)
    subject.delete("bar", owner, target)
    
    subject.check("bar", owner).should be_false
    subject.check("bar", owner, StubTarget).should be_false
    subject.check("bar", owner, target).should be_false
  end
  
  it "should allow to fetch list of permissions for current role" do 
    subject.set("bar", owner)
    subject.set("bar", owner, target)
    class << owner; def id; 20; end; end
    subject.set("bar", owner, StubTarget)
    
    (subject.permissions("bar") - ["15", "15/StubTarget/10", "20/StubTarget"]).should be_empty
    subject.permissions("lala").should be_empty
  end 
  
  it "should allow to fetch whole list of roles" do 
    subject.set("foo", owner)
    subject.set("bar", owner)
    subject.set("bla", owner)
    
    (subject.roles - ["foo", "bar", "bla"]).should be_empty 
  end
  
  it "should allow to fetch list of roles for specified member" do 
    subject.set("foo", owner)
    subject.set("bar", owner)
    subject.set("bla", owner)
    
    (subject.roles(owner.id) - ["foo", "bar", "bla"]).should be_empty
    subject.roles(33).should be_empty
  end
end

describe "Aclatraz" do
  let(:owner) { StubOwner.new }
  let(:target) { StubTarget.new }
  
  describe "Redis store" do 
    before(:all) { @redis = Thread.new { `redis-server` } }
    after(:all) { @redis.exit! }
    subject { Aclatraz.init(:redis, "redis://localhost:6379/0") }
    before(:each) { subject.clear }
    
    class_eval &STORE_SPECS
  end
end
