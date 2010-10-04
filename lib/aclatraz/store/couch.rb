begin
  require "couchrest"
rescue LoadError
  raise "You must install the couchrest gem to use the CouchDB store"
end

module Aclatraz
  module Store
    # List of global roles are stored in `roles => all` key. Each suspect has its 
    # own key, which contains list of assigned roles. Roles are stored in
    # following format:
    #
    #   roles => { 
    #     "suspect.{:suspect_id}" => [
    #       "role_name",
    #       "role_name/ClassName",
    #       "role_name/ObjectClass/object_id"
    #     ]
    #   }
    class Couch
      include Aclatraz::Helpers

      ALL_ROLES_KEY     = "all"
      SUSPECT_ROLES_KEY = "suspect.%s"

      def initialize(document, database, *args) # :nodoc:
        @document = document
        
        @backend  = if args.first.respond_to?(:documents)
          args.first
        else
          CouchRest.new(*args).database!(database)
        end
        
        begin
          @backend.get(@document)
        rescue RestClient::ResourceNotFound
          create_roles_doc
        end
      end

      def set(role, suspect, object=nil)
        @backend.update_doc(@document) do |doc| 
          doc[ALL_ROLES_KEY] << role.to_s
          doc[SUSPECT_ROLES_KEY % suspect_id(suspect)] ||= []
          doc[SUSPECT_ROLES_KEY % suspect_id(suspect)] << pack(role.to_s, object)
          doc
        end
      end

      def roles(suspect=nil)
        #roles = []
        #@backend.keys.each do |key|
        #  @backend.exists?(key) ? perm = unpack(key) : next
        #  if perm.size == 2 && (!suspect || (suspect && perm[0].to_s == suspect_id(suspect)))
        #    roles.push(perm[1])
        #  end
        #end
        #roles.compact.uniq
      end

      def check(role, suspect, object=nil)
        #@backend.exists?(pack(role.to_s, suspect_id(suspect), object)) or begin
        #  object && !object.is_a?(Class) ? check(role, suspect, object.class) : false
        #end
      end

      def delete(role, suspect, object=nil)
        @backend.update_doc(@document) do |doc|
          doc[SUSPECT_ROLES_KEY % suspect_id(suspect)].delete(pack(role.to_s, object))
          doc
        end
      end

      def clear
        @backend.update_doc(@document) {|doc| doc.destroy; doc } 
      rescue RestClient::ResourceNotFound
        # nothing to do...
      ensure
        create_roles_doc
      end
      
      def create_roles_doc
        @backend.save_doc({"_id" => @document, ALL_ROLES_KEY => []})
      end
    end # Couch
  end # Store
end # Aclatraz
