describe "Aclatraz" do
  it "should raise InvalidStore error when given store doesn't exists" do 
    lambda { Aclatraz.store(:fooobar) }.should raise_error(Aclatraz::InvalidStore)
  end
  
  it "should raise StoreNotInitialized error when store has not been set yet" do 
    lambda { Aclatraz.store }.should raise_error(Aclatraz::StoreNotInitialized)
  end
  
  it "should properly set datastore when class given" do 
    class TestStore; end
    lambda { Aclatraz.store(TestStore) }.should_not raise_error
    Aclatraz.store.should be_kind_of(TestStore)
  end
  
  describe "Redis store" do 
    before(:all) { @redis = Thread.new { `redis-server` } }
    after(:all) { @redis.exit! }
    subject { Aclatraz.store(:redis, "redis://localhost:6379/0") }
    before(:each) { subject.clear }
    
    class StubOwner; def id; 15; end; end
    class StubTarget; def id; 10; end; end
    
    let(:owner) { StubOwner.new }
    let(:target) { StubTarget.new }
    
    it "should properly assign given roles to owner and check permissions" do
      subject.set("foo", owner)
      subject.check("foo", owner).should be_true
      
      subject.set("bar", owner, StubTarget)
      subject.check("bar", owner, StubTarget).should be_true
      
      subject.set("bla", owner, target)
      subject.check("bla", owner, target).should be_true
      
      subject.check("foo", owner, target).should be_false
      subject.check("foo", owner, StubTarget).should be_false
      subject.check("bar", owner).should be_false
    end
    
    it "should properly delete given permission" do
      subject.set("foo", owner)
      subject.set("bar", owner, StubTarget)
      subject.set("bla", owner, target)
      
      subject.delete("bar", owner)
      subject.delete("bar", owner, StubTarget)
      subject.delete("bar", owner, target)
      
      subject.check("bar", owner).should be_false
      subject.check("bar", owner, StubTarget).should be_false
      subject.check("bar", owner, target).should be_false
    end
    
    it "should allow to fetch list of members for current role" do 
      subject.set("bar", owner, StubTarget)
      subject.set("bar", owner, target)
      class << owner; def id; 20; end; end
      subject.set("bar", owner, target)
      
      (subject.members("bar") - ["15", "20"]).should be_empty
      subject.members("lala").should be_empty
    end 
    
    it "should allow to fetch whole list of roles" do 
      subject.set("foo", owner)
      subject.set("bar", owner)
      subject.set("bla", owner)
      
      (subject.roles - ["foo", "bar", "bla"]).should be_empty 
    end
    
    it "should allow to fetch list of roles for specified member" do 
      subject.set("foo", owner)
      subject.set("bar", owner)
      subject.set("bla", owner)
      
      (subject.roles(owner.id) - ["foo", "bar", "bla"]).should be_empty
      subject.roles(33).should be_empty
    end
  end
end
