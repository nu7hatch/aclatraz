begin
  require 'redis'
  require 'redis/distributed'
rescue LoadError
  raise "You must install the redis gem to use the Redis store"
end

module Aclatraz
  module Store
    # List of global roles are stored in ROLES set. Each member has its 
    # own key, which contains list of assigned roles. Roles are stored in
    # following format:
    #
    #   member.{:member_id}.roles:
    #     "role_name"
    #     "role_name/ClassName"
    #     "role_name/ObjectClass/object_id"
    class Redis
      include Aclatraz::Helpers
      
      ROLES = "roles"
      MEMBER_ROLES = "member.%s.roles"
      
      def initialize(*args) # :nodoc:
        @backend = if args.first.respond_to?(:sadd)
          args.first
        else
          ::Redis.new(*args)
        end
      end

      def set(role, member, object=nil)
        @backend.multi do
          @backend.sadd(ROLES, role.to_s) unless object
          @backend.sadd(MEMBER_ROLES % member_id(member), pack(role.to_s, object))
        end
      end
      
      def roles(member=nil)
        if member
          @backend.smembers(MEMBER_ROLES % member_id(member)).map {|role|
            role = unpack(role)
            role[0] if role.size == 1
          }.compact.uniq
        else
          @backend.smembers(ROLES)
        end
      end
      
      def check(role, member, object=nil)
        @backend.sismember(MEMBER_ROLES % member_id(member), pack(role.to_s, object)) or begin
          object && !object.is_a?(Class) ? check(role, member, object.class) : false
        end
      end
      
      def delete(role, member, object=nil)
        @backend.srem(MEMBER_ROLES % member_id(member), pack(role.to_s, object))
      end
      
      def clear
        @backend.flushdb
      end
      
      private
      
      # Pack given permission data.
      #
      #   pack(foo)               # => "foo"
      #   pack(foo, "FooClass")   # => "foo/FooClass"
      #   pack(foo, FooClass.new) # => "foo/FooClass/{foo_object_ID}"
      def pack(role, object=nil)
        case object
        when nil
          [role]
        when Class 
          [role, object.name]
        else 
          [role, object.class.name, object.id]
        end.join("/")
      end
      
      # Unpack given permission data.
      def unpack(data)
        data.to_s.split("/")
      end
    end # Redis
  end # Store
end # Aclatraz
