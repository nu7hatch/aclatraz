$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require "rubygems"
require "aclatraz"

Aclatraz.store :redis

class Account
  include Aclatraz::Suspect
  def id; 30; end  
end

@account = Account.new
10000.times do |x|
  @account.has_role?("foo#{x}")
end
