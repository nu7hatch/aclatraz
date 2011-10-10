require './lib/aclatraz/version'

Gem::Specification.new do |s|
  s.name = "aclatraz"
  s.author = "Chris Kowalik <chris@nu7hat.ch>"
  s.email = "chris@nu7hat.ch"
  s.homepage = "http://github.com/nu7hatch/aclatraz"
  s.license = 'MIT'
  s.summary = "Flexible access control mechanism!"
  s.description = "Extremaly fast, flexible and intuitive access control mechanism, powered by fast key value stores like Redis."
  s.files = Dir["lib/**/*"] + ["LICENSE", "README.rdoc", "CHANGELOG.rdoc"]
  s.version = Aclatraz::VERSION
  s.add_dependency('dictionary', '~> 1.0.0')
  s.add_development_dependency('rspec', '~> 2.6.0')
  s.add_development_dependency('mocha', '~> 0.10.0')
  s.add_development_dependency('redis', '~> 2.2.2')
  s.add_development_dependency('riak-client', '~> 0.9.8')
  s.add_development_dependency('cassandra', '~> 0.12.1')
  s.add_development_dependency('mongo', '~> 0.4.0')
end
