require 'dictionary'

require 'aclatraz/helpers'
require 'aclatraz/store'
require 'aclatraz/acl'
require 'aclatraz/guard'
require 'aclatraz/suspect'

module Aclatraz
  class AccessDenied < Exception; end 
  class InvalidSuspect < ArgumentError; end
  class InvalidPermission < ArgumentError; end
  class InvalidStore < ArgumentError; end
  class StoreNotInitialized < Exception; end
  
  extend Helpers
  
  def self.init(klass, *args)
    klass = eval("Aclatraz::Store::#{camelize(klass.to_s)}") unless klass.is_a?(Class)
    @store = klass.new(*args)
  rescue NameError
    raise InvalidStore, "The #{klass.inspect} ACL store is not defined!"
  end
  
  def self.store
    @store or raise StoreNotInitialized, "ACLatraz is not initialized!"
  end
end
