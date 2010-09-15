begin
  require 'redis'
rescue LoadError
  raise "You must install the redis gem to use the Redis store"
end

module Aclatraz
  module Store
    class Redis
      include Aclatraz::Helpers
      
      ROLES_KEY = "aclatraz.roles"
      MEMBER_ROLES_KEY = "member.%s.roles"
      
      def initialize(*args) # :nodoc:
        @backend = ::Redis.new(*args)
      end

      def set(role, owner, object=nil)
        @backend.multi do
          unless object
            @backend.hset(ROLES_KEY, role, 1)
            @backend.hset(MEMBER_ROLES_KEY % owner.id.to_s, role, 1)
          end
          @backend.sadd(role.to_s, pack(owner.id, object))
        end
      end
      
      def roles(member=nil)
        if member
          @backend.hkeys(MEMBER_ROLES_KEY % member.id.to_s)
        else
          @backend.hkeys(ROLES_KEY)
        end
      end
      
      def check(role, owner, object=nil)
        @backend.sismember(role.to_s, pack(owner.id, object)) or begin
          object && !object.is_a?(Class) ? check(role, owner, object.class) : false
        end
      end
      
      def delete(role, owner, object=nil)
        @backend.srem(role.to_s, pack(owner.id, object))
      end
      
      def clear
        @backend.flushdb
      end
    end # Redis
  end # Store
end # Aclatraz
