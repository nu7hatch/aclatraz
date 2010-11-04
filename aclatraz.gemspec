# -*- ruby -*-
$:.unshift(File.expand_path('../lib', __FILE__))
require 'aclatraz/version'

Gem::Specification.new do |s|
  s.name             = 'aclatraz'
  s.version          = Aclatraz.version
  s.homepage         = 'http://github.com/nu7hatch/aclatraz'
  s.email            = ['chris@nu7hat.ch']
  s.authors          = ['Chris Kowalik']
  s.summary          = %q{Flexible access control mechanism!}
  s.description      = %q{Extremaly fast, flexible and intuitive access control mechanism, powered by fast key value stores like Redis.}
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths    = %w[lib]
  s.extra_rdoc_files = %w[LICENSE README.rdoc CHANGELOG.rdoc TODO.rdoc]

  s.add_runtime_dependency     'dictionary',  ['~> 1.0']
  s.add_development_dependency 'rspec',       ["~> 2.0"]
  s.add_development_dependency 'mocha',       [">= 0.9"]
  s.add_development_dependency 'redis',       [">= 2.0"]
  s.add_development_dependency 'riak-client', [">= 0.8"]
  s.add_development_dependency 'cassandra',   [">= 0.8"]
end
