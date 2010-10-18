require 'spec_helper'

describe "Aclatraz ACL" do
  subject { Aclatraz::ACL } 
  before(:all) { Aclatraz.init(:redis, "redis://localhost:6379/0") }
  
  it "should properly set suspect" do 
    acl = subject.new(:suspect) {}
    acl.suspect.should == :suspect
  end
  
  it "should properly store flat access control lists" do
    acl = subject.new(:suspect) {} 
    acl.actions[:_].allow :admin
    acl.permissions[:admin].should be_true
    acl.actions[:_].deny :admin
    acl.permissions[:admin].should be_false
    acl.actions[:_].allow :owner_of => :book
    acl.permissions[{:owner_of => :book}].should be_true
  end
  
  it "should allow for grouping permissions in namespaces, which are inherit from main block" do 
    acl = subject.new(:suspect) do 
      allow :admin
      on(:library) { allow :librarian }
      on(:kitchen) { allow :cooker }
      on(:kennel)  { allow :dog }
    end
    
    acl.permissions[:admin].should be_true
    acl.permissions[:librarian].should be_false
    acl.permissions[:cooker].should be_false
    acl.permissions[:dog].should be_false
    
    acl[:library].permissions[:librarian].should be_true
    acl[:library].permissions[:cooker].should be_false
    acl[:library].permissions[:dog].should be_false
    acl[:library].permissions[:admin].should be_false
    
    acl[:kitchen].permissions[:cooker].should be_true
    acl[:kitchen].permissions[:librarian].should be_false
    acl[:kitchen].permissions[:dog].should be_false
    acl[:kitchen].permissions[:admin].should be_false
  end
  
  it "should raise error when no block given" do 
    lambda { Aclatraz::ACL.new }.should raise_error(ArgumentError)
  end
end
