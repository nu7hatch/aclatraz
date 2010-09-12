$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

$VERBOSE = nil

require 'rubygems'
require 'aclatraz'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  config.mock_with :mocha
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
