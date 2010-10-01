begin
  require 'cassandra'
rescue LoadError
  raise "You must install the casssandra gem to use the Cassandra store"
end

module Aclatraz
  module Store
    # List of global roles are stored in `roles => all` key. Each member has its 
    # own key, which contains list of assigned roles. Roles are stored in
    # following format:
    #
    #   roles => member.{:member_id} =>
    #     "role_name" => ""
    #     "role_name/ClassName" => ""
    #     "role_name/ObjectClass/object_id" => ""
    class Cassandra
      include Aclatraz::Helpers
      
      ROLES        = "roles"
      ROLES_ALL    = "all"
      ROLES_MEMBER = "member.%s"
      
      def initialize(*args) # :nodoc:
        @family  = args.shift
        @backend = if args.first.respond_to?(:keyspace)
          args.first
        else
          ::Cassandra.new(*args)
        end
      end
      
      def set(role, member, object=nil)
        data = {}
        data[ROLES_ALL] = [role.to_s] unless object
        data[ROLES_MEMBER % member_id(member)] = [pack(role.to_s, object)]
        @backend.insert(@family, ROLES, data)
      end
      
      def roles(member=nil)
        if member
          data = @backend.get(@family, ROLES, ROLES_MEMBER % member_id(member))
          data ? data.keys.map {|role| unpack(role) }.flatten.compact.uniq : []
        else
          data = @backend.get(@family, ROLES, ROLES_ALL)
          data ? data.keys.flatten : []
        end
      end
      
      def check(role, member, object=nil)
        @backend.exists?(@family, ROLES, ROLES_MEMBER % member_id(member), pack(role.to_s, object)) or begin
          object && !object.is_a?(Class) ? check(role, member, object.class) : false
        end
      end
      
      def delete(role, member, object=nil)
        @backend.remove(@family, ROLES, ROLES_MEMBER % member_id(member), pack(role.to_s, object))
      end
      
      def clear
        @backend.remove(@family, ROLES)
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
