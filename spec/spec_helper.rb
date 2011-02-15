$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$VERBOSE = nil

require 'aclatraz'
require 'mocha'
require 'rspec'

RSpec.configure do |config|
  config.mock_with :mocha
  config.filter_run_excluding :store => lambda { |store|
    begin
      require store
      false
    rescue LoadError
      true
    end
  }
end

class StubSuspect
  include Aclatraz::Suspect
  def id; 10; end 
end

class StubGuarded
  include Aclatraz::Guard
  class << self
    attr_accessor :name
  end
end

class StubTarget
  def id; 10; end
end

class StubOwner
  def id; 15; end
end

class GuardedParent
  include Aclatraz::Guard
  def user; @user ||= StubSuspect.new; end
  suspects :user do
    allow :cooker
    deny :waiter
  end
end

class GuardedChild < GuardedParent
  suspects do
    deny :cooker
    allow :manager
  end
end

class StubStore
end
