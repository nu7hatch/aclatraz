require 'spec_helper'

describe "Aclatraz suspect" do 
  before(:all) { Aclatraz.store(:redis, "redis://localhost:6379/0") }
  subject { StubSuspect.new }
  let(:target) { StubTarget.new }
  
  its(:acl_suspect?) { should be_true }
  
  it "1: should properly set given role" do 
    subject.assign_role!(:foobar1)
    subject.assign_role!(:foobar2, StubTarget)
    subject.assign_role!(:foobar3, target) 
    
    Aclatraz.store.permissions(:foobar1).should include("10")
    Aclatraz.store.permissions(:foobar2).should include("10/StubTarget")
    Aclatraz.store.permissions(:foobar3).should include("10/StubTarget/10")
  end
  
  it "2: should properly check given permissions" do 
    subject.has_role?(:foobar1).should be_true
    subject.has_role?(:foobar2, StubTarget).should be_true
    subject.has_role?(:foobar3, target).should be_true
    subject.has_role?(:foobar1, StubTarget).should be_false
  end
  
  it "3: should allow to get list of roles assigned to user" do 
    (subject.roles - ["foobar1", "foobar2", "foobar3"]) .should be_empty
  end
  
  it "4: should properly remove given permissions" do 
    subject.delete_role!(:foobar1)
    subject.delete_role!(:foobar2, StubTarget)
    subject.delete_role!(:foobar3, target) 
    
    subject.has_role?(:foobar1).should be_false
    subject.has_role?(:foobar2, StubTarget).should be_false
    subject.has_role?(:foobar3, target).should be_false
  end
  
  describe "syntactic sugars" do 
    it "1: should properly set given role" do 
      subject.is.foobar1!
      subject.is.foobar2_of!(StubTarget)
      subject.is.foobar3_for!(target)
      subject.is.foobar4_on!(target) 
      subject.is.foobar5_at!(target)
      subject.is.foobar6_by!(target)
      subject.is.foobar7_in!(target)
      
      subject.has_role?(:foobar1).should be_true
      subject.has_role?(:foobar2_of, StubTarget).should be_true
      subject.has_role?(:foobar3_for, target).should be_true
      subject.has_role?(:foobar4_of, target).should be_true
      subject.has_role?(:foobar5_at, target).should be_true
      subject.has_role?(:foobar6_by, target).should be_true
      subject.has_role?(:foobar7_in, target).should be_true
    end
    
    it "2: should properly check given permissions" do 
      subject.is.foobar1?.should be_true
      subject.is.foobar2_of?(StubTarget).should be_true
      subject.is.foobar3_for?(target).should be_true
      subject.is.foobar4_on?(target).should be_true
      subject.is.foobar5_at?(target).should be_true
      subject.is.foobar6_by?(target).should be_true
      subject.is.foobar7_in?(target).should be_true
      subject.is.foobar8_in?.should be_false
      
      subject.is_not.foobar1?.should be_false
      subject.is_not.foobar2_of?(StubTarget).should be_false
      subject.is_not.foobar3_for?(target).should be_false
      subject.is_not.foobar4_on?(target).should be_false
      subject.is_not.foobar5_at?(target).should be_false
      subject.is_not.foobar6_by?(target).should be_false
      subject.is_not.foobar7_in?(target).should be_false
      subject.is_not.foobar8_in?.should be_true
    end
    
    it "3: should properly remove given permissions" do 
      subject.is_not.foobar1!
      subject.is_not.foobar2_of!(StubTarget)
      subject.is_not.foobar3_for!(target)
      subject.is_not.foobar4_on!(target) 
      subject.is_not.foobar5_at!(target)
      subject.is_not.foobar6_by!(target)
      subject.is_not.foobar7_in!(target)
      
      subject.is.foobar1?.should be_false
      subject.is.foobar2_of?(StubTarget).should be_false
      subject.is.foobar3_for?(target).should be_false
      subject.is.foobar4_on?(target).should be_false
      subject.is.foobar5_at?(target).should be_false
      subject.is.foobar6_by?(target).should be_false
      subject.is.foobar7_in?(target).should be_false
    end
    
    it "4: should raise NoMethodError when there is not checker or setter/deleter called" do
      lambda { subject.is.foobar }.should raise_error(NoMethodError)
      lambda { subject.is_not.foobar }.should raise_error(NoMethodError)
    end
  end
end
