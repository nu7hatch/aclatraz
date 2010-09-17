require 'yaml'

begin
  require "riak"
rescue LoadError
  raise "You must install the redis-client gem to use the Riak store"
end

module Aclatraz
  module Store
    # The most optimal way to store roles in riak database is pack everything
    # in a single key name, eg:
    #
    #   :suspect_id/:role_name 
    #   :suspect_id/:role_name/:ClassName 
    #   :suspect_id/:role_name/:ObjectClass/object_id
    class Riak
      include Aclatraz::Helpers

      def initialize(bucket_name, *args) # :nodoc:
        @backend = ::Riak::Client.new(*args).bucket(bucket_name)
      end

      def set(role, owner, object=nil)
        obj = @backend.get_or_new(pack(role.to_s, owner.id, object))
        obj.content_type = "text/plain"
        obj.data = 1
        obj.store
      end

      def roles(member=nil)
        roles = []
        @backend.keys.each do |key|
          perm = unpack(@backend.get(key)) rescue next
          if perm.size < 3 && (!member || (member && perm[0] == member.id.to_s))
            roles.push(role)
          end  
        end
        roles.uniq
      end

      def check(role, owner, object=nil)
        @backend.exists?(pack(role.to_s, owner.id, object)) or begin
          object && !object.is_a?(Class) ? check(role, owner, object.class) : false
        end
      end

      def delete(role, owner, object=nil)
        @backend.delete(pack(role.to_s, owner.id, object))
      end

      def clear
        # not optimal... yea but there is no other way to clear all keys 
        # in the riak bucket -_-"
        @backend.keys.each {|key| @backend.delete(key) }
      end

      private

      # Pack given permission data.
      #
      #   pack("foo", 10)               # => "10/foo"
      #   pack("foo", 10, "FooClass")   # => "10/foo/FooClass"
      #   pack("foo", 10, FooClass.new) # => "10/foo/FooClass/{foo_object_ID}"
      def pack(role, owner, object=nil)
        case object
        when nil
          "#{owner}/#{role}"
        when Class 
          "#{owner}/#{role}/#{object.name}"
        else 
          "#{owner}/#{role}/#{object.class.name}/#{object.id}"
        end
      end
      
      # Unpack given permission data.
      def unpack(data)
        data.to_s.split("/")
      end
    end # Riak
  end # Store
end # Aclatraz
