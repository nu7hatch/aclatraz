require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "aclatraz"
    gem.summary = %Q{Flexible access control that doesn't sucks!}
    gem.description = <<-DESCR
      Extremaly fast and flexible access control mechanism inspired by *nix ACLs, 
      powered by fast key value stores like Redis or TokyoCabinet.
    DESCR
    gem.email = "kriss.kowalik@gmail.com"
    gem.homepage = "http://github.com/nu7hatch/aclatraz"
    gem.authors = ["Kriss 'nu7hatch' Kowalik"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "mocha", ">= 0.9"
    gem.add_development_dependency "redis", "~> 2.0"
    gem.add_development_dependency "riak-client", "~> 0.8"
    gem.add_dependency "dictionary", "~> 1.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
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
