require 'dictionary'

module Aclatraz
  require 'aclatraz/errors'
  require 'aclatraz/helpers'
  require 'aclatraz/store'
  require 'aclatraz/acl'
  require 'aclatraz/guard'
  require 'aclatraz/suspect'
  require 'aclatraz/version'
  
  extend Helpers

  # Initialize Aclatraz system with given datastore. 
  #
  #   Aclatraz.init :redis, :host => "127.0.0.1", :database => 0
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
