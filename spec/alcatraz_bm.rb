$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "aclatraz"

Aclatraz.init :redis, "redis://localhost:6379/0"

class Account
  include Aclatraz::Suspect
  def id; 30; end
end

$account = Account.new
$account.is.bla_of!($account)

class Foo
  include Aclatraz::Guard
  
  suspects :account do
    allow :foo
    deny :bar
    on :foo do
      allow :bla_of => $account
      allow :foo
    end
    on :bar do 
      allow :bar
    end
  end
  
  def account
    $account
  end
  
  def test
    guard!(:foo, :bar)
  rescue
  end  
end

$foo = Foo.new

ns = [1000, 2000, 5000, 10000]

ns.each do |n|
  puts "#{n} times:"
  Benchmark.bm(10) do |bm| 
    bm.report("Assign:") { n.times {|x| $account.assign_role!("foo#{x}") } }
    bm.report("Check:")  { n.times {|x| $account.has_role?("foo#{x}") } }
    bm.report("Guard:")  { n.times {|x| $foo.test } }
    bm.report("Delete:") { n.times {|x| $account.delete_role!("foo#{x}") } }
  end
  puts
end

