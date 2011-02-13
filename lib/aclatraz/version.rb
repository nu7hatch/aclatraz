module Aclatraz
  class Version #:nodoc:
    MAJOR  = 0
    MINOR  = 1
    PATCH  = 4
    STRING = [MAJOR, MINOR, PATCH].join('.')
  end # Version
  
  def self.version # :nodoc:
    Version::STRING
  end 
end # Gmail
