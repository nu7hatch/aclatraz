require 'aclatraz/helpers'
require 'aclatraz/store'
require 'aclatraz/acl'
require 'aclatraz/guard'
require 'aclatraz/suspect'

$VERBOSE = nil

module Aclatraz
  class AccessDenied < Exception; end 
  class InvalidSuspect < ArgumentError; end
  class InvalidPermission < ArgumentError; end
  class InvalidStore < ArgumentError; end
  class StoreNotInitialized < Exception; end
  
  extend Helpers
  
  def self.store(klass=nil, *args)
    if klass
      begin
        klass = eval("Aclatraz::Store::#{camelize(klass.to_s)}") unless klass.is_a?(Class)
        @store = klass.new(*args)
      rescue NameError
        raise InvalidStore, "The #{klass.inspect} ACL store is not defined!"
      end
    else
      @store or raise StoreNotInitialized
    end    
  end
end
