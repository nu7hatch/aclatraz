# -*- ruby -*-

$:.unshift(File.expand_path('../lib', __FILE__))
require 'aclatraz/version'

begin
  Ore::Specification.new do |gemspec|
    gemspec.version = Aclatraz.version
  end
rescue NameError
  begin
    require 'ore/specification'
    retry
  rescue LoadError
    STDERR.puts "The '#{__FILE__}' file requires Ore."
    STDERR.puts "Run `gem install ore-core` to install Ore."
  end
end
