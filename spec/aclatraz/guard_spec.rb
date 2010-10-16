require 'spec_helper'

describe "Aclatraz guard" do 
  before(:all) { Aclatraz.init(:redis, "redis://localhost:6379/0") }
  let(:suspect) { @foo ||= StubSuspect.new }
  
  subject { Class.new(StubGuarded) }
 
  it "#acl_guard? should be true" do 
    subject.acl_guard?.should be_true
  end
  
  it "should properly guard permissions" do
    guarded_class = subject
    guarded_class.name = "test1"
    
    guarded_class.suspects suspect do 
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
    guarded_class.suspects do 
      allow :role5
    end
    
    guarded_class.class_eval do 
      def target; @target = StubTarget.new; end
    end
    
    guarded = guarded_class.new
    
    lambda { guarded.guard! }.should raise_error(Aclatraz::AccessDenied)
    suspect.is.role1!
    lambda { guarded.guard! }.should_not raise_error(Aclatraz::AccessDenied)
    suspect.is.role2!
    lambda { guarded.guard! }.should raise_error(Aclatraz::AccessDenied) 
    suspect.is.role5!
    lambda { guarded.guard! }.should_not raise_error(Aclatraz::AccessDenied)
    
    lambda { guarded.guard!(:bar) }.should_not raise_error(Aclatraz::AccessDenied)
    suspect.is_not.role5!
    lambda { guarded.guard!(:bar) }.should raise_error(Aclatraz::AccessDenied)
    suspect.is_not.role2!
    lambda { guarded.guard!(:bar) }.should_not raise_error(Aclatraz::AccessDenied)
    suspect.is_not.role1!
    lambda { guarded.guard!(:bar) }.should raise_error(Aclatraz::AccessDenied)
    suspect.is.role3!
    lambda { guarded.guard!(:bar) }.should_not raise_error(Aclatraz::AccessDenied)
    suspect.is.role4!(StubTarget)
    lambda { guarded.guard!(:bar) }.should raise_error(Aclatraz::AccessDenied)
    
    lambda { guarded.guard!(:bla) }.should raise_error(Aclatraz::AccessDenied)
    suspect.is_not.role3!
    suspect.is.role1!
    lambda { guarded.guard!(:bla) }.should_not raise_error(Aclatraz::AccessDenied)
    suspect.is_not.role1!
    lambda { guarded.guard!(:bla) }.should raise_error(Aclatraz::AccessDenied)
    suspect.is.role2!(guarded.target)
    lambda { guarded.guard!(:bla) }.should_not raise_error(Aclatraz::AccessDenied)
    suspect.is_not.role2!(guarded.target)
    bar = StubTarget.new
    guarded.instance_variable_set('@bar', bar)
    suspect.is.role6!(bar)
    lambda { guarded.guard!(:bla) }.should_not raise_error(Aclatraz::AccessDenied)
    suspect.is.role3!
    lambda { guarded.guard!(:bla) }.should_not raise_error(Aclatraz::AccessDenied)
    suspect.is_not.role6!(bar)
    suspect.is.role5!
    lambda { guarded.guard!(:bla) }.should raise_error(Aclatraz::AccessDenied)
    suspect.is_not.role3!
    lambda { guarded.guard!(:bla) }.should_not raise_error(Aclatraz::AccessDenied)
    
    suspect.is_not.role5!
    suspect.is_not.role4!(StubTarget)
    lambda { guarded.guard!(:bar, :bla) }.should raise_error(Aclatraz::AccessDenied)
    suspect.is.role1!
    lambda { guarded.guard!(:bar, :bla) }.should_not raise_error(Aclatraz::AccessDenied)
    suspect.is.role4!(StubTarget)
    lambda { guarded.guard!(:bar, :bla) }.should raise_error(Aclatraz::AccessDenied)
    suspect.is.role2!(guarded.target)
    lambda { guarded.guard!(:bar, :bla) }.should_not raise_error(Aclatraz::AccessDenied)
    
    lambda { guarded.guard!(:allow_all) }.should_not raise_error(Aclatraz::AccessDenied)
    lambda { guarded.guard!(:deny_all) }.should raise_error(Aclatraz::AccessDenied)
    
    lambda { guarded.guard!(:bar, :allow_all, :bla) }.should_not raise_error(Aclatraz::AccessDenied)
    suspect.is_not.role2!(guarded.target)
    lambda { guarded.guard!(:bar, :allow_all, :bla) }.should_not raise_error(Aclatraz::AccessDenied)
    suspect.is.role3! 
    lambda { guarded.guard!(:bar, :allow_all, :bla) }.should raise_error(Aclatraz::AccessDenied)
    
    suspect.is_not.role3!
    lambda { guarded.guard!(:bar, :deny_all, :bla) }.should raise_error(Aclatraz::AccessDenied)
    suspect.is.role2!(guarded.target)
    lambda { guarded.guard!(:bar, :deny_all, :bla) }.should_not raise_error(Aclatraz::AccessDenied)
    
    lambda { guarded.guard! { deny :role2 => :target } }.should raise_error(Aclatraz::AccessDenied)
  end
  
  it "when invalid permission given then #guard! should raise InvalidPermission error" do 
    guarded_class = subject
    guarded_class.name = "test2"
    guarded_class.suspects(suspect) { allow Object.new }
    guarded = guarded_class.new
    lambda { guarded.guard! }.should raise_error(Aclatraz::InvalidPermission)
  end
  
  it "when invalid suspect given then #guard! should raise InvalidSuspect error" do 
    guarded_class = subject
    guarded_class.name = "test3"
    guarded_class.suspects('bar') { }
    guarded = guarded_class.new
    lambda { guarded.guard! }.should raise_error(Aclatraz::InvalidSuspect)
  end

  it "when ACL is not defined then #guard! should raise UndefinedAccessControlList error" do 
    guarded_class = subject
    guarded_class.name = "test4"
    guarded = guarded_class.new
    lambda { guarded.guard! }.should raise_error(Aclatraz::UndefinedAccessControlList)
  end
  
  it "when given suspect name is symbol then #suspect should reference to instance method" do 
    guarded_class = subject
    guarded_class.name = "test5"
    guarded_class.suspects(:foo) {}
    guarded = guarded_class.new
    guarded.class.class_eval { def foo; @foo ||= StubSuspect.new; end } 
    guarded.suspect.should == guarded.foo
  end

  it "when given suspect name is string #suspect should reference to instance variable" do 
    guarded_class = subject
    guarded_class.name = "test6"
    guarded_class.suspects('foo') {}
    guarded = guarded_class.new
    guarded.instance_variable_set("@foo", StubSuspect.new)
    guarded.suspect.should == guarded.instance_variable_get("@foo")
  end
  
  it "when given suspect is an object then #suspect should refence to it" do 
    bar = StubSuspect.new
    guarded_class = subject
    guarded_class.name = "test7"
    guarded_class.suspects(bar) {}
    guarded = guarded_class.new
    guarded.suspect.should == bar
  end 
  
  context "inherited guards" do 
    class FooParent
      include Aclatraz::Guard
      
      suspects :user do
        allow :nested1
        deny :nested2
      end
      
      def user; @user ||= StubSuspect.new; end
    end
    
    class BarChild < FooParent
      suspects do
        deny :nested1
        allow :nested3
      end
    end
    
    it "should work properly" do
      foo = FooParent.new
      bar = BarChild.new
      
      lambda { foo.guard! }.should raise_error(Aclatraz::AccessDenied)
      foo.user.is.nested1!
      lambda { foo.guard! }.should_not raise_error(Aclatraz::AccessDenied)
      foo.user.is.nested2!
      lambda { foo.guard! }.should raise_error(Aclatraz::AccessDenied)
      
      bar.user.is_not.nested1!
      bar.user.is_not.nested2!
      
      lambda { bar.guard! }.should raise_error(Aclatraz::AccessDenied)
      bar.user.is.nested1!
      lambda { bar.guard! }.should raise_error(Aclatraz::AccessDenied)
      bar.user.is.nested2!
      lambda { bar.guard! }.should raise_error(Aclatraz::AccessDenied)
      bar.user.is.nested3!
      lambda { bar.guard! }.should_not raise_error(Aclatraz::AccessDenied)
    end
  end
end
