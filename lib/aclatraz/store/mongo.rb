require 'mongo'

module Aclatraz
  module Store
    # For MongoDB, each role is stored in separate row:
    #
    #   {"roles" => [
    #     {"suspect" => 1, "role" => "admin" },
    #     {"suspect" => 2, "role" => "manager/ClassName" },
    #     {"suspect" => 3, "role" => "owner/ClassName/1" }
    #   ]}
    class Mongo
      include Aclatraz::Helpers

      ROLE_KEY    = "role"
      SUSPECT_KEY = "suspect"

      def initialize(collection, mongo)
        @backend    = mongo
        @collection = collection
      end

      def set(role, suspect, object=nil)
        @backend[@collection].insert(make_doc(role, suspect, object))
      end

      def roles(suspect=nil)
        if suspect
          roles = @backend[@collection].find(SUSPECT_KEY => suspect_id(suspect)).map {|row| row[ROLE_KEY] }
        else
          roles = @backend[@collection].find.map {|row| row[ROLE_KEY] }
        end
        roles.compact.uniq
      end

      def check(role, suspect, object=nil)
        @backend[@collection].find(make_doc(role, suspect, object)).map.empty? == false or begin
          object && !object.is_a?(Class) ? check(role, suspect, object.class) : false
        end
      end

      def delete(role, suspect, object=nil)
        @backend[@collection].remove(make_doc(role, suspect, object))
      end

      def clear
        @backend[@collection].remove
      end
      
      private
      
      def make_doc(role, suspect, object)
        { SUSPECT_KEY => suspect_id(suspect), ROLE_KEY => pack(role.to_s, object) }
      end
    end # Mongo
  end # Store
end # Aclatraz
