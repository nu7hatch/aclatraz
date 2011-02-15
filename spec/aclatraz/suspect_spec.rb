require File.dirname(__FILE__) + '/../spec_helper'

describe "Aclatraz suspect" do 
  before(:all) { Aclatraz.init(:redis, "redis://localhost:6379/0") }
  subject { StubSuspect.new }
  let(:target) { StubTarget.new }
  
  it "#acl_suspect? should be true" do
    subject.should be_acl_suspect
  end
  
  it "should properly set given role" do 
    subject.roles.assign(:first)
    subject.roles.assign(:second, StubTarget)
    subject.roles.assign(:third, target) 
    
    subject.roles.has?(:first).should be_true
    subject.roles.has?(:second, StubTarget).should be_true
    subject.roles.has?(:third, target).should be_true
  end
  
  it "should properly check given permissions" do 
    subject.roles.has?(:first).should be_true
    subject.roles.has?(:second, StubTarget).should be_true
    subject.roles.has?(:third, target).should be_true
    subject.roles.has?(:first, StubTarget).should be_false
  end
  
  it "should allow to get list of roles assigned to user" do 
    (subject.roles.all - ["first", "second", "third"]) .should be_empty
  end
  
  it "should properly remove given permissions" do 
    subject.roles.delete(:first)
    subject.roles.delete(:second, StubTarget)
    subject.roles.delete(:third, target) 
    
    subject.roles.has?(:first).should be_false
    subject.roles.has?(:second, StubTarget).should be_false
    subject.roles.has?(:third, target).should be_false
  end
  
  context "syntactic sugars" do 
    it "should properly set given role" do 
      subject.is.first!
      subject.is.second_of!(StubTarget)
      subject.is.third_for!(target)
      subject.is.fourth_on!(target) 
      subject.is.fifth_at!(target)
      subject.is.sixth_by!(target)
      subject.is.seventh_in!(target)
      
      subject.roles.has?(:first).should be_true
      subject.roles.has?(:second_of, StubTarget).should be_true
      subject.roles.has?(:third_for, target).should be_true
      subject.roles.has?(:fourth_of, target).should be_true
      subject.roles.has?(:fifth_at, target).should be_true
      subject.roles.has?(:sixth_by, target).should be_true
      subject.roles.has?(:seventh_in, target).should be_true
    end
    
    it "should properly check given permissions" do 
      subject.is.first?.should be_true
      subject.is.second_of?(StubTarget).should be_true
      subject.is.third_for?(target).should be_true
      subject.is.fourth_on?(target).should be_true
      subject.is.fifth_at?(target).should be_true
      subject.is.sixth_by?(target).should be_true
      subject.is.seventh_in?(target).should be_true
      subject.is.eighth_in?.should be_false
      
      subject.is_not.first?.should be_false
      subject.is_not.second_of?(StubTarget).should be_false
      subject.is_not.third_for?(target).should be_false
      subject.is_not.fourth_on?(target).should be_false
      subject.is_not.fifth_at?(target).should be_false
      subject.is_not.sixth_by?(target).should be_false
      subject.is_not.seventh_in?(target).should be_false
      subject.is_not.eighth_in?.should be_true
    end
    
    it "should properly remove given permissions" do 
      subject.is_not.first!
      subject.is_not.second_of!(StubTarget)
      subject.is_not.third_for!(target)
      subject.is_not.fourth_on!(target) 
      subject.is_not.fifth_at!(target)
      subject.is_not.sixth_by!(target)
      subject.is_not.seventh_in!(target)
      
      subject.is.first?.should be_false
      subject.is.second_of?(StubTarget).should be_false
      subject.is.third_for?(target).should be_false
      subject.is.fourth_on?(target).should be_false
      subject.is.fifth_at?(target).should be_false
      subject.is.sixth_by?(target).should be_false
      subject.is.seventh_in?(target).should be_false
    end
    
    it "should raise NoMethodError when there is not checker or setter/deleter called" do
      lambda { subject.is.foobar }.should raise_error(NoMethodError)
      lambda { subject.is_not.foobar }.should raise_error(NoMethodError)
    end
  end
end
