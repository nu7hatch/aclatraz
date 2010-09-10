begin
  require 'redis'
rescue LoadError
  raise "You must install redis to use the Redis store backend"
end

module Aclatraz
  module Store
    class Redis < Base
      def initialize(*args)
        @backend = ::Redis.new(*args)
      end

      def set(role, owner, object=nil)
        @backend.sadd(role, pack(owner, object))
      end
      
      def list(role)
        @backend.smembers(role)
      end
      
      def check(role, owner, object=nil)
        @backend.sismember(role, pack(owner, object))
      end
      
      def delete(role, owner, object)
        @backend.srem(role, pack(owner, object)
      end
    end
  end
end
