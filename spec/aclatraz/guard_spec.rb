require 'spec_helper'

describe "Aclatraz guard" do 
  include Aclatraz::Guard
  
  suspects :foo do 
    allow :foobar1
    deny :foobar2
    
    on :bar do
      allow :foobar3
      deny :foobar4
    end
    
    on :bla do 
      deny :foobar1
      allow :foobar2
    end
    
    allow :foobar5
  end
  
  it "should properly store name of suspected object" do 
    self.class.acl_suspect.should == :foo
  end
  
  it "should properly store permissions" do 
    self.class.acl_permissions.should be_kind_of(Aclatraz::ACL)
  end
end
