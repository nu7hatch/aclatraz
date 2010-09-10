begin
  require 'redis'
rescue LoadError
  raise "You must install redis to use the Redis store backend"
end

module Aclatraz
  module Store
    class Redis < Base
      ROLES_KEY = "aclatraz.roles"
      MEMBER_ROLES_KEY = "member.%s.roles"
      
      def initialize(*args)
        @backend = ::Redis.new(*args)
      end

      def set(role, owner, object=nil)
        @backend.multi do
          unless object
            @backend.hset(ROLES_KEY, role, 1)
            @backend.hset(MEMBER_ROLES_KEY % owner.id.to_s, role, 1)
          end
          @backend.sadd(role, pack(owner.id, object))
        end
      end
      
      def members(role)
        @backend.smembers(role).map {|m| m.split('/').first }.uniq
      end
      
      def roles(member=nil)
        if member
          @backend.hkeys(MEMBER_ROLES_KEY % member.id.to_s)
        else
          @backend.hkeys(ROLES_KEY)
        end
      end
      
      def check(role, owner, object=nil)
        @backend.sismember(role, pack(owner.id, object))
      end
      
      def delete(role, owner, object=nil)
        @backend.srem(role, pack(owner.id, object))
      end
      
      def clear
        @backend.flushdb
      end
    end
  end
end
