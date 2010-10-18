require 'spec_helper'

describe "Aclatraz" do
  context "on init" do
    it "should raise error when given store is invalid" do 
      lambda { 
        Aclatraz.init(:invalid_data_store) 
      }.should raise_error(Aclatraz::InvalidStore)
    end
  
    it "should set data store when it is valid" do 
      lambda { 
        Aclatraz.init(StubStore) 
        Aclatraz.store.should be_kind_of(StubStore)
      }.should_not raise_error
    end
  end
  
  it "should raise error when store has not been initialized yet" do 
    lambda { 
      Aclatraz.instance_variable_set('@store', nil)
      Aclatraz.store 
    }.should raise_error(Aclatraz::StoreNotInitialized)
  end
end
