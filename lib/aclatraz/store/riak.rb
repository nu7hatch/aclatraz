begin
  require 'riak'
rescue LoadError
  raise "You must install the ripple gem to use the Riak store"
end
require 'yaml'

module Aclatraz
  module Store
    class Riak
      include Aclatraz::Helpers

      BUCKET_NAME      = "aclatraz"
      ROLES_KEY        = "roles"
      MEMBER_ROLES_KEY = "member.%s.roles"

      def initialize(*args) # :nodoc:
        @backend = ::Riak::Client.new(*args).bucket(BUCKET_NAME)
      end

      def set(role, owner, object=nil)
        unless object
          sadd(ROLES_KEY, role)
          sadd(MEMBER_ROLES_KEY % owner.id.to_s, role)
        end
        sadd(role.to_s, pack(owner.id, object))
      end

      def roles(member=nil)
        if member
          vget(MEMBER_ROLES_KEY % member.id.to_s, [])
        else
          vget(ROLES_KEY, [])
        end
      end

      def check(role, owner, object=nil)
        vget(role.to_s, []).include?(pack(owner.id, object)) or begin
          object && !object.is_a?(Class) ? check(role, owner, object.class) : false
        end
      end

      def delete(role, owner, object=nil)
        srem(role.to_s, pack(owner.id, object))
      end

      def clear
        # not optimal
        @backend.keys do |keys|
          keys.each { |k| @backend.delete(k) }
        end
      end

      private

        def sadd(key, item)
          items = vget(key, [])
          items |= [item]
          vset(key, items)
        end

        def srem(key, item)
          items = vget(key, [])
          items.delete(item)
          vset(key, items)
        end

        def vget(key, default=nil)
          YAML::load(@backend.get_or_new(key).data || '') || default
        end

        def vset(key, value)
          obj = @backend.get_or_new(key)
          obj.content_type = 'text/x-yaml'
          obj.data = YAML::dump(value)
          obj.store
        end

    end # Riak
  end # Store
end # Aclatraz
