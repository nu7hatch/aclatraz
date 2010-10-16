require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "aclatraz"
    gem.email = "kriss.kowalik@gmail.com"
    gem.homepage = "http://github.com/nu7hatch/aclatraz"
    gem.authors = ["Kriss 'nu7hatch' Kowalik"]
    gem.summary = %Q{Flexible access control that doesn't sucks!}
    gem.description = <<-DESCR
      Extremaly fast, flexible and intuitive access control mechanism, 
      powered by fast key value stores like Redis.
    DESCR
    gem.add_dependency "dictionary", "~> 1.0"
    gem.add_development_dependency "rspec", "~> 2.0"
    gem.add_development_dependency "mocha", "~> 0.9"
    gem.add_development_dependency "redis", "~> 2.0"
    gem.add_development_dependency "riak-client", "~> 0.8"
    gem.add_development_dependency "cassandra", "~> 0.8"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = %q[--colour --backtrace]
end

RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rspec_opts = %q[--colour --backtrace]
  t.rcov_opts = %q[--exclude "spec" --text-report]
end

task :spec => :check_dependencies
task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ACLatraz #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :benchmark do 
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
  require 'benchmark'
  require "aclatraz"
  
  task :redis do 
    Aclatraz.init(:redis)
    require File.dirname(__FILE__)+"/spec/alcatraz_bm"
  end
  task :cassandra do 
    Aclatraz.init(:cassandra, "Super1", "Keyspace1")
    require File.dirname(__FILE__)+"/spec/alcatraz_bm"
  end
  task :riak do
    Aclatraz.init(:riak, "roles")
    require File.dirname(__FILE__)+"/spec/alcatraz_bm"
  end
end
