# -*- ruby -*-
$:.unshift(File.expand_path('../lib', __FILE__))
require 'aclatraz/version'
require 'rspec/core/rake_task'
require 'rake/rdoctask'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = %q[-c -b]
end

RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rspec_opts = %q[-c -b]
  t.rcov_opts = %q[-T -x "spec"]
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ACLatraz #{Aclatraz.version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :spec

desc "Build current version as a rubygem"
task :build do
  `gem build aclatraz.gemspec`
  `mv aclatraz-*.gem pkg/`
end

desc "Relase current version to rubygems.org"
task :release => :build do
  `git tag -am "Version bump to #{Aclatraz.version}" v#{Aclatraz.version}`
  `git push origin master`
  `git push origin master --tags`
  `gem push pkg/aclatraz-#{Aclatraz.version}.gem`
end

namespace :benchmark do 
  require 'aclatraz'
  require 'benchmark'
  
  benchmarks = File.expand_path("../spec/alcatraz_bm.rb", __FILE__)
  
  desc "Redis store benchmarks"
  task :redis do 
    Aclatraz.init(:redis)
    load benchmarks
  end
  
  desc "Cassandra store benchmarks"
  task :cassandra do 
    Aclatraz.init(:cassandra, "Super1", "Keyspace1")
    load benchmarks
  end
  
  desc "Riak store benchmarks"
  task :riak do
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
