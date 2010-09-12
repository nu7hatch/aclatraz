require 'spec_helper'

describe "Aclatraz" do
  describe "on init" do
    it "should raise InvalidStore error when given store doesn't exists" do 
      lambda { Aclatraz.init(:fooobar) }.should raise_error(Aclatraz::InvalidStore)
    end
  
    it "should properly set datastore when class given" do 
      class TestStore; end
      lambda { Aclatraz.init(TestStore) }.should_not raise_error
      Aclatraz.store.should be_kind_of(TestStore)
    end
  end
  
  it "should raise StoreNotInitialized error when store has not been set yet" do 
    Aclatraz.instance_variable_set('@store', nil)
    lambda { Aclatraz.store }.should raise_error(Aclatraz::StoreNotInitialized)
  end
end
