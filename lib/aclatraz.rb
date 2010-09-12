require 'dictionary'

require 'aclatraz/helpers'
require 'aclatraz/store'
require 'aclatraz/acl'
require 'aclatraz/guard'
require 'aclatraz/suspect'

module Aclatraz
  # Raised when suspect don't have permission to execute action
  class AccessDenied < Exception; end 
  
  # Raised when suspect specified in guarded class is invalid
  class InvalidSuspect < ArgumentError; end
  
  # Raised when invalid permission is set in ACL
  class InvalidPermission < ArgumentError; end
  
  # Raised when try to initialize invalid datastore
  class InvalidStore < ArgumentError; end
  
  # Raised when datastore is not initialized when managing permission
  class StoreNotInitialized < Exception; end
  
  # Raised when try to guard class without any ACL defined
  class UndefinedAccessControlList < Exception; end
  
  extend Helpers

  # Initialize Aclatraz system with given datastore. 
  #
  #   Aclatraz.init :redis, "redis://localhost:6379/0"
  #   Aclatraz.init :tokyocabinet, "./permissions.tch"
  #   Aclatraz.init MyCustomDatastore, :option => 1 # ...
  def self.init(store, *args)
    store = eval("Aclatraz::Store::#{camelize(store.to_s)}") unless store.is_a?(Class)
    @store = store.new(*args)
  rescue NameError
    raise InvalidStore, "The #{store.inspect} ACL store is not defined!"
  end
  
  # Returns current datastore object, or raises +StoreNotInitialized+ when 
  # +init+ method wasn't called before. 
  def self.store
    @store or raise StoreNotInitialized, "ACLatraz is not initialized!"
  end
  
  # Access control lists fof all classes protected by Aclatraz. 
  def self.acl
    @acl ||= {}
  end
end # Aclatraz
