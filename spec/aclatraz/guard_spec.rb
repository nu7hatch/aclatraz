require 'spec_helper'

describe "Aclatraz guard" do 
  subject { Class.new(StubGuarded) }
  let(:suspect) { @suspect ||= StubSuspect.new }
  before(:all) { Aclatraz.init(:redis, "redis://localhost:6379/0") }
  define_method(:deny_access) { raise_error(Aclatraz::AccessDenied) }
 
  it "#acl_guard? should be true" do 
    subject.acl_guard?.should be_true
  end
  
  it "should properly guard permissions" do
    guarded_class = subject
    guarded_class.name = "FirstGuarded"
    
    guarded_class.suspects suspect do 
      allow :manager
      deny  :client
      on :bar do
        allow :bartender
        deny  :owner => StubTarget
      end
      on :kitchen do 
        deny  :bartender
        allow :client_of => :target
        allow :cleaner_of => 'bar'
      end
      on :deny_all do 
        deny all
      end
      on :allow_all do 
        allow all
      end
    end
    guarded_class.suspects do 
      allow :boss
    end
    
    guarded_class.class_eval do 
      def target; @target = StubTarget.new; end
    end
    
    guarded = guarded_class.new
    
    lambda { guarded.guard! }.should deny_access
    lambda { suspect.is.manager!; guarded.guard! }.should_not deny_access
    lambda { suspect.is.client!; guarded.guard! }.should deny_access 
    lambda { suspect.is.boss!; guarded.guard! }.should_not deny_access
    
    lambda { guarded.guard!(:bar) }.should_not deny_access
    lambda { suspect.is_not.boss!; guarded.guard!(:bar) }.should deny_access
    lambda { suspect.is_not.client!; guarded.guard!(:bar) }.should_not deny_access
    lambda { suspect.is_not.manager!; guarded.guard!(:bar) }.should deny_access
    lambda { suspect.is.bartender!; guarded.guard!(:bar) }.should_not deny_access
    lambda { suspect.is.owner!(StubTarget); guarded.guard!(:bar) }.should deny_access
    
    lambda { guarded.guard!(:kitchen) }.should deny_access
    lambda { 
      suspect.is_not.bartender!
      suspect.is.manager!
      guarded.guard!(:kitchen) 
    }.should_not deny_access
    lambda { suspect.is_not.manager!; guarded.guard!(:kitchen) }.should deny_access
    lambda { suspect.is.client!(guarded.target); guarded.guard!(:kitchen) }.should_not deny_access
    
    bar = StubTarget.new
    guarded.instance_variable_set('@bar', bar)
    
    lambda { 
      suspect.is_not.client!(guarded.target)
      suspect.is.cleaner!(bar)
      guarded.guard!(:kitchen) 
    }.should_not deny_access
    
    lambda { suspect.is.bartender!; guarded.guard!(:kitchen) }.should_not deny_access
    lambda { 
      suspect.is_not.cleaner!(bar)
      suspect.is.boss!
      guarded.guard!(:kitchen) 
    }.should deny_access
    lambda { suspect.is_not.bartender!; guarded.guard!(:kitchen) }.should_not deny_access
    
    lambda { 
      suspect.is_not.boss!
      suspect.is_not.owner!(StubTarget)
      guarded.guard!(:bar, :kitchen) 
    }.should deny_access
    lambda { suspect.is.manager!; guarded.guard!(:bar, :kitchen) }.should_not deny_access
    lambda { suspect.is.owner!(StubTarget); guarded.guard!(:bar, :kitchen) }.should deny_access
    lambda { suspect.is.client!(guarded.target); guarded.guard!(:bar, :kitchen) }.should_not deny_access
    
    lambda { guarded.guard!(:allow_all) }.should_not deny_access
    lambda { guarded.guard!(:deny_all) }.should deny_access
    
    lambda { guarded.guard!(:bar, :allow_all, :kitchen) }.should_not deny_access
    lambda { 
      suspect.is_not.client!(guarded.target)
      guarded.guard!(:bar, :allow_all, :kitchen) 
    }.should_not deny_access
    lambda { 
      suspect.is.bartender!
      guarded.guard!(:bar, :allow_all, :kitchen) 
    }.should deny_access
    
    lambda { 
      suspect.is_not.bartender!
      guarded.guard!(:bar, :deny_all, :kitchen) 
    }.should deny_access
    lambda { 
      suspect.is.client!(guarded.target)
      guarded.guard!(:bar, :deny_all, :kitchen) 
    }.should_not deny_access
    
    lambda { guarded.guard! { deny :client => :target } }.should deny_access
  end
  
  it "should raise error when invalid permission given" do 
    lambda { 
      guarded_class = subject
      guarded_class.name = "SecondGuarded"
      guarded_class.suspects(suspect) { allow Object.new }
      guarded = guarded_class.new
      guarded.guard! 
    }.should raise_error(Aclatraz::InvalidPermission)
  end
  
  it "should raise error when invalid suspect given" do 
    lambda { 
      guarded_class = subject
      guarded_class.name = "ThirdGuarded"
      guarded_class.suspects('invalid_suspect') { }
      guarded = guarded_class.new
      guarded.guard! 
    }.should raise_error(Aclatraz::InvalidSuspect)
  end

  it "should raise error when ACL is not defined" do 
    lambda { 
      guarded_class = subject
      guarded_class.name = "FourthGuarded"
      guarded = guarded_class.new
      guarded.guard! 
    }.should raise_error(Aclatraz::UndefinedAccessControlList)
  end
  
  it "suspect should reference to instance method when given suspect name is kind of symbol" do 
    guarded_class = subject
    guarded_class.name = "FifthGuarded"
    guarded_class.suspects(:user) {}
    guarded = guarded_class.new
    guarded.class.class_eval { def user; @user ||= StubSuspect.new; end } 
    guarded.suspect.should == guarded.user
  end

  it "suspect should reference to instance variable when given suspect name is kind of string" do 
    guarded_class = subject
    guarded_class.name = "SixthGuarded"
    guarded_class.suspects('user') {}
    guarded = guarded_class.new
    guarded.instance_variable_set("@user", StubSuspect.new)
    guarded.suspect.should == guarded.instance_variable_get("@user")
  end
  
  it "suspect should reference to given object if passed" do 
    suspect = StubSuspect.new
    guarded_class = subject
    guarded_class.name = "SeventhGuarded"
    guarded_class.suspects(suspect) {}
    guarded = guarded_class.new
    guarded.suspect.should == suspect
  end 
  
  it "should properly resolve inherited permissions" do
    parent = GuardedParent.new
    child  = GuardedChild.new
    
    child.user.is_not.cooker!
    child.user.is_not.waiter!
    child.user.is_not.manager!
    
    lambda { parent.guard! }.should deny_access
    lambda { parent.user.is.cooker!; parent.guard! }.should_not deny_access
    lambda { parent.user.is.waiter!; parent.guard! }.should deny_access
    
    child.user.is_not.cooker!
    child.user.is_not.waiter!
    
    lambda { child.guard! }.should deny_access
    lambda { child.user.is.cooker!; child.guard! }.should deny_access
    lambda { child.user.is.waiter!; child.guard! }.should deny_access
    lambda { child.user.is.manager!; child.guard! }.should_not deny_access
  end
end
