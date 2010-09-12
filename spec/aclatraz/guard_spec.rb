require 'spec_helper'

describe "Aclatraz guard" do 
  include Aclatraz::Guard
  
  before(:all) { Aclatraz.init(:redis, "redis://localhost:6379/0") }
  let(:foo) { @foo ||= StubSuspect.new }
  let(:target) { StubTarget.new }
  
  suspects :foo do 
    allow :role1
    deny :role2
    on :bar do
      allow :role3
      deny :role4 => StubTarget
    end
    on :bla do 
      deny :role3
      allow :role2 => :target
      allow :role6 => 'bar'
    end
    on :deny_all do 
      deny all
    end
    on :allow_all do 
      allow all
    end
  end
  suspects do 
    allow :role5
  end
  
  it "should properly store name of suspected object" do 
    self.class.acl_suspect.should == :foo
  end
  
  it "should properly store permissions" do 
    self.class.acl_permissions.should be_kind_of(Aclatraz::ACL)
  end
  
  it "should properly guard permissions" do
    access_denied = Aclatraz::AccessDenied
   
    lambda { guard! }.should raise_error(access_denied)
    foo.is.role1!
    lambda { guard! }.should_not raise_error(access_denied)
    foo.is.role2!
    lambda { guard! }.should raise_error(access_denied) 
    foo.is.role5!
    lambda { guard! }.should_not raise_error(access_denied)
    
    lambda { guard!(:bar) }.should_not raise_error(access_denied)
    foo.is_not.role5!
    lambda { guard!(:bar) }.should raise_error(access_denied)
    foo.is_not.role2!
    lambda { guard!(:bar) }.should_not raise_error(access_denied)
    foo.is_not.role1!
    lambda { guard!(:bar) }.should raise_error(access_denied)
    foo.is.role3!
    lambda { guard!(:bar) }.should_not raise_error(access_denied)
    foo.is.role4!(StubTarget)
    lambda { guard!(:bar) }.should raise_error(access_denied)
    
    lambda { guard!(:bla) }.should raise_error(access_denied)
    foo.is_not.role3!
    foo.is.role1!
    lambda { guard!(:bla) }.should_not raise_error(access_denied)
    foo.is_not.role1!
    lambda { guard!(:bla) }.should raise_error(access_denied)
    foo.is.role2!(target)
    lambda { guard!(:bla) }.should_not raise_error(access_denied)
    foo.is_not.role2!(target)
    @bar = StubTarget.new
    foo.is.role6!(@bar)
    lambda { guard!(:bla) }.should_not raise_error(access_denied)
    foo.is.role3!
    lambda { guard!(:bla) }.should_not raise_error(access_denied)
    foo.is_not.role6!(@bar)
    foo.is.role5!
    lambda { guard!(:bla) }.should raise_error(access_denied)
    foo.is_not.role3!
    lambda { guard!(:bla) }.should_not raise_error(access_denied)
    
    foo.is_not.role5!
    foo.is_not.role4!(StubTarget)
    lambda { guard!(:bar, :bla) }.should raise_error(access_denied)
    foo.is.role1!
    lambda { guard!(:bar, :bla) }.should_not raise_error(access_denied)
    foo.is.role4!(StubTarget)
    lambda { guard!(:bar, :bla) }.should raise_error(access_denied)
    foo.is.role2!(target)
    lambda { guard!(:bar, :bla) }.should_not raise_error(access_denied)
    
    lambda { guard!(:allow_all) }.should_not raise_error(access_denied)
    lambda { guard!(:deny_all) }.should raise_error(access_denied)
    
    lambda { guard!(:bar, :allow_all, :bla) }.should_not raise_error(access_denied)
    foo.is_not.role2!(target)
    lambda { guard!(:bar, :allow_all, :bla) }.should_not raise_error(access_denied)
    foo.is.role3! 
    lambda { guard!(:bar, :allow_all, :bla) }.should raise_error(access_denied)
    
    foo.is_not.role3!
    lambda { guard!(:bar, :deny_all, :bla) }.should raise_error(access_denied)
    foo.is.role2!(target)
    lambda { guard!(:bar, :deny_all, :bla) }.should_not raise_error(access_denied)
  end
  
  describe "ivalid permission" do 
    suspects(:foo) { allow Object.new }
    
    it "#check_permissions should raise InvalidPermission error" do 
      lambda { guard! }.should raise_error(Aclatraz::InvalidPermission)
    end
  end
  
  describe "invalid suspect" do 
    suspects('bar') { }
    
    it "#guard! should raise InvalidSuspect error" do 
      lambda { guard! }.should raise_error(Aclatraz::InvalidSuspect)
    end
  end
  
  describe "suspect object is symbol" do
    suspects(:foo) {}

    it "#suspect" do 
      suspect.should == foo
    end
  end
    
  describe "suspect object is string" do
    suspects('foo') {}
    
    it "#suspect" do 
      @foo = StubSuspect.new
      suspect.should == @foo
    end
  end
  
  describe "suspect object includes Suspect class" do 
    bar = StubSuspect.new
    suspects(bar) {}
    
    it "#suspect" do 
      suspect.should == bar
    end
  end 
end
