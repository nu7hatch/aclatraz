require 'spec_helper'

class StubSuspect
  include Aclatraz::Suspect
  def id; 10; end 
end

class StubTarget
  def id; 10; end
end

describe "Aclatraz suspect" do 
  subject { StubSuspect.new }
  let(:target) { StubTarget.new }
  
  it "1: should properly set given role and allow to check" do 
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
end
