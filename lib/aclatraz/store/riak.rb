require 'riak'

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

      def initialize(bucket_name, *args)
        @backend = if args.first.respond_to?(:bucket)
          args.first.bucket(bucket_name)
        else
          ::Riak::Client.new(*args).bucket(bucket_name)
        end
      end

      def set(role, suspect, object=nil)
        obj = @backend.new(pack(role.to_s, suspect_id(suspect), object))
        obj.content_type = "text/plain"
        obj.data = "1"
        obj.store
      end

      def roles(suspect=nil)
        roles = []
        # Also this can be a little bit slow...
        @backend.keys.each do |key|
          @backend.exists?(key) ? perm = unpack(key) : next
          if perm.size == 2 && (!suspect || (suspect && perm[0].to_s == suspect_id(suspect)))
            roles.push(perm[1])
          end
        end
        roles.compact.uniq
      end

      def check(role, suspect, object=nil)
        @backend.exists?(pack(role.to_s, suspect_id(suspect), object)) or begin
          object && !object.is_a?(Class) ? check(role, suspect, object.class) : false
        end
      end

      def delete(role, suspect, object=nil)
        @backend.delete(pack(role.to_s, suspect_id(suspect), object))
      end

      def clear
        # not optimal... yea but there is no other way to clear all keys 
        # in the riak bucket -_-"
        @backend.keys.each {|key| @backend.delete(key) }
      end

      # Pack given permission data.
      #
      #   pack("foo", 10)               # => "10/foo"
      #   pack("foo", 10, "FooClass")   # => "10/foo/FooClass"
      #   pack("foo", 10, FooClass.new) # => "10/foo/FooClass/{foo_object_ID}"
      def pack(role, suspect, object=nil)
        case object
        when nil
          [suspect, role]
        when Class 
          [suspect, role, object.name]
        else 
          [suspect, role, object.class.name, object.id]
        end.join("/")
      end
    end # Riak
  end # Store
end # Aclatraz
