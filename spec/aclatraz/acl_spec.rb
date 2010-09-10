require 'spec_helper'

describe "Aclatraz ACL" do 
  it "should properly store flat access control lists" do
    acl = Aclatraz::ACL.new do 
      allow :foo
      deny :bar
      allow :foo => :bar
    end
    
    acl.allowed.should include(:foo)
    acl.denied.should include(:bar)
    acl.allowed.should include({:foo=>:bar})
  end
  
  it "should define seperated lists in actions" do 
    acl = Aclatraz::ACL.new do 
      allow :foo
      
      on :spam do 
        allow :spam
      end
      
      on :eggs do 
        allow :eggs
      end
    end
    
    acl.allowed.should include(:foo)
    acl.allowed.should_not include(:spam)
    acl.allowed.should_not include(:eggs)
    acl[:spam].allowed.should include(:spam)
    acl[:eggs].allowed.should include(:eggs)
  end
  
  it "should raise ArgumentError when no block given" do 
    lambda { Aclatraz::ACL.new }.should raise_error(ArgumentError)
  end
end
