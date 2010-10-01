begin
  require 'cassandra'
rescue LoadError
  raise "You must install the casssandra gem to use the Cassandra store"
end

module Aclatraz
  module Store
    # List of global roles are stored in `roles => all` key. Each suspect has its 
    # own key, which contains list of assigned roles. Roles are stored in
    # following format:
    #
    #   roles => suspect.{:suspect_id} =>
    #     "role_name" => ""
    #     "role_name/ClassName" => ""
    #     "role_name/ObjectClass/object_id" => ""
    class Cassandra
      include Aclatraz::Helpers
      
      ROLES_KEY         = "roles"
      ALL_ROLES_KEY     = "all"
      SUSPECT_ROLES_KEY = "suspect.%s"
      
      def initialize(*args) # :nodoc:
        @family  = args.shift
        @backend = if args.first.respond_to?(:keyspace)
          args.first
        else
          ::Cassandra.new(*args)
        end
      end
      
      def set(role, suspect, object=nil)
        data = {}
        data[ALL_ROLES_KEY] = [role.to_s] unless object
        data[SUSPECT_ROLES_KEY % suspect_id(suspect)] = [pack(role.to_s, object)]
        @backend.insert(@family, ROLES_KEY, data)
      end
      
      def roles(suspect=nil)
        if suspect
          data = @backend.get(@family, ROLES_KEY, SUSPECT_ROLES_KEY % suspect_id(suspect))
          data ? data.keys.map {|role| unpack(role) }.flatten.compact.uniq : []
        else
          data = @backend.get(@family, ROLES_KEY, ALL_ROLES_KEY)
          data ? data.keys.flatten : []
        end
      end
      
      def check(role, suspect, object=nil)
        @backend.exists?(@family, ROLES_KEY, SUSPECT_ROLES_KEY % suspect_id(suspect), \
          pack(role.to_s, object)) or \
          object && !object.is_a?(Class) ? check(role, suspect, object.class) : false
      end
      
      def delete(role, suspect, object=nil)
        @backend.remove(@family, ROLES_KEY, SUSPECT_ROLES_KEY % suspect_id(suspect), \
          pack(role.to_s, object))
      end
      
      def clear
        @backend.remove(@family, ROLES_KEY)
      end
    end # Redis
  end # Store
end # Aclatraz
