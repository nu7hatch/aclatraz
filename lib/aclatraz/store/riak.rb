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
        case args.first when ::Riak::Client
          @backend = args.first.bucket(bucket_name)
        else
          @backend = ::Riak::Client.new(*args).bucket(bucket_name)
        end
      end

      def set(role, member, object=nil)
        obj = @backend.new(pack(role.to_s, member_id(member), object))
        obj.content_type = "text/plain"
        obj.data = "1"
        obj.store
      end

      def roles(member=nil)
        roles = []
        # Also this can be a little bit slow...
        @backend.keys.each do |key|
          @backend.exists?(key) ? perm = unpack(key) : next
          if perm.size == 2 && (!member || (member && perm[0].to_s == member_id(member)))
            roles.push(perm[1])
          end
        end
        roles.compact.uniq
      end

      def check(role, member, object=nil)
        @backend.exists?(pack(role.to_s, member_id(member), object)) or begin
          object && !object.is_a?(Class) ? check(role, member, object.class) : false
        end
      end

      def delete(role, member, object=nil)
        @backend.delete(pack(role.to_s, member_id(member), object))
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
      def pack(role, member, object=nil)
        case object
        when nil
          "#{member}/#{role}"
        when Class 
          "#{member}/#{role}/#{object.name}"
        else 
          "#{member}/#{role}/#{object.class.name}/#{object.id}"
        end
      end
      
      # Unpack given permission data.
      def unpack(data)
        data.to_s.split("/")
      end
    end # Riak
  end # Store
end # Aclatraz
