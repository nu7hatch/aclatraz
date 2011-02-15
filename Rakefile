# -*- ruby -*-

$:.unshift(File.expand_path('../lib', __FILE__))
require 'aclatraz/version'

begin
  require 'ore/tasks'
  Ore::Tasks.new
rescue LoadError => e
  STDERR.puts e.message
  STDERR.puts "Run `gem install ore-tasks` to install 'ore/tasks'."
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  task :spec do
    abort 'Run `gem install rspec` to install RSpec'
  end
end

task :test => :spec
task :default => :test

begin 
  require 'metric_fu'
rescue LoadError
  STDERR.puts e.message
  STDERR.puts "Run `gem install metric_fu` to install Metric-Fu"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ACLatraz #{Aclatraz.version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :benchmark do 
  require 'aclatraz'
  require 'benchmark'

  benchmarks = File.expand_path("../spec/alcatraz_bm.rb", __FILE__)
  
  desc "Redis store benchmarks"
  task :redis do 
    require 'redis'
    Aclatraz.init(:redis)
    load benchmarks
  end
  
  desc "Cassandra store benchmarks"
  task :cassandra do 
    require 'cassandra'
    Aclatraz.init(:cassandra, "Super1", "Keyspace1")
    load benchmarks
  end
  
  desc "Riak store benchmarks"
  task :riak do
    require 'riak-client'
    Aclatraz.init(:riak, "roles")
    load benchmarks
  end
  
  desc "MongoDB store benchmarks"
  task :mongo do
    require 'mongo'
    Aclatraz.init(:mongo, "roles", Mongo::Connection.new.db("aclatraz_test"))
    load benchmarks
  end
end
