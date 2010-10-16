require 'spec_helper'

STORE_SPECS = proc do
  it "should properly assign given roles to owner and check permissions" do
    subject.clear
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
    subject.clear
    subject.set("foo", owner)
    subject.set("bar", owner, StubTarget)
    subject.set("bla", owner, target)
    
    subject.delete("foo", owner)
    subject.delete("bar", owner, StubTarget)
    subject.delete("bla", owner, target)
    
    subject.check("bar", owner).should be_false
    subject.check("bar", owner, StubTarget).should be_false
    subject.check("bar", owner, target).should be_false
  end
  
  it "should allow to fetch whole list of roles" do 
    subject.set("foo", owner)
    subject.set("bar", owner)
    subject.set("bla", owner)
    
    subject.roles.should_not be_empty
    (subject.roles - ["foo", "bar", "bla"]).should be_empty 
  end
  
  it "should allow to fetch list of roles for specified member" do 
    subject.set("foo", owner)
    subject.set("bar", owner)
    subject.set("bla", owner)
    
    subject.roles(owner).should_not be_empty
    (subject.roles(owner) - ["foo", "bar", "bla"]).should be_empty
  end
end

describe "Aclatraz" do
  let(:owner) { StubOwner.new }
  let(:target) { StubTarget.new }
  
  context "for Redis store" do 
    subject { Aclatraz.init(:redis, "redis://localhost:6379/0") }
    
    class_eval &STORE_SPECS
    
    it "should respect persistent connection given on initalize" do 
      Aclatraz.instance_variable_set("@store", nil)
      Aclatraz.init(:redis, Redis.new("redis://localhost:6379/0"))
      Aclatraz.store.instance_variable_get('@backend').should be_kind_of(Redis)
      Aclatraz.store.instance_variable_get('@backend').ping.should be_true
    end
    
    it "shouls respect redis hash options given in init" do 
      Aclatraz.instance_variable_set("@store", nil)
      Aclatraz.init(:redis, :url => "redis://localhost:6379/2")
      Aclatraz.store.instance_variable_get('@backend').ping.should be_true
    end 
  end

  context "for Riak store" do 
    subject { Aclatraz.init(:riak, "roles") }
    
    class_eval &STORE_SPECS
    
    it "should respect persistent connection given on initalize" do 
      Aclatraz.instance_variable_set("@store", nil)
      Aclatraz.init(:riak, "roles", Riak::Client.new)
      Aclatraz.store.instance_variable_get('@backend').should be_kind_of(Riak::Bucket)
    end
  end
  
  context "for Cassandra store" do 
    subject { Aclatraz.init(:cassandra, "Super1", "Keyspace1") }
  
    class_eval &STORE_SPECS
  
    it "should respect persistent connection given on initialize" do 
      Aclatraz.instance_variable_set("@store", nil)
      Aclatraz.init(:cassandra, "Super1", Cassandra.new("Keyspace1"))
      Aclatraz.store.instance_variable_get('@backend').should be_kind_of(Cassandra)
    end
  end
end
