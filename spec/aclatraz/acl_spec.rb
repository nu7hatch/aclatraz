require 'spec_helper'

describe "Aclatraz ACL" do 
  before(:all) { Aclatraz.init(:redis, "redis://localhost:6379/0") }
  
  it "should properly store flat access control lists" do
    acl = Aclatraz::ACL.new {} 
    acl.actions[:_].allow :foo
    acl.permissions[:foo].should be_true
    acl.actions[:_].deny :foo
    acl.permissions[:foo].should be_false
    acl.actions[:_].allow :foo => :bar
    acl.permissions[{:foo=>:bar}].should be_true
  end
  
  it "should allow for define seperated lists which are inherit from main block" do 
    acl = Aclatraz::ACL.new do 
      allow :foo
      on(:spam) { allow :spam }
      on(:eggs) { allow :eggs }
      on(:spam) { allow :boo }
    end
    
    acl.permissions[:foo].should be_true
    acl.permissions[:spam].should_not be_true
    acl.permissions[:eggs].should_not be_true
    acl.permissions[:boo].should_not be_true
    acl[:spam].permissions[:foo].should be_nil
    acl[:spam].permissions[:spam].should be_true
    acl[:spam].permissions[:eggs].should be_nil
    acl[:spam].permissions[:boo].should be_true
    acl[:eggs].permissions[:foo].should be_nil
    acl[:eggs].permissions[:eggs].should be_true
    acl[:eggs].permissions[:spam].should be_nil
  end
  
  it "should raise ArgumentError when no block given" do 
    lambda { Aclatraz::ACL.new }.should raise_error(ArgumentError)
  end
end
