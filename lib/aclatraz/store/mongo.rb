require 'mongo'

module Aclatraz
  module Store
    # For mongo each role is stored in separated row:
    #
    #   {"roles" => [
    #     {"suspect" => 1, "role" => "admin" },
    #     {"suspect" => 2, "role" => "manager/ClassName" },
    #     {"suspect" => 3, "role" => "owner/ClassName/1" }
    #   ]}
    class Mongo
      include Aclatraz::Helpers

      def initialize(collection, mongo)
        @backend = mongo if args.first.respond_to?(:database_info)
        @collection = collection
      end

      def set(role, suspect, object=nil)
        @backend[collection].insert(make_doc(role, suspect, object))
      end

      def roles(suspect=nil)
        if suspect
          @backend[collection].find("suspect" => suspect_id(suspect)).map {|row| row["role"] }
        else
          @backend[collection].find.map {|row| row["role"] }
        end.compact.uniq
      end

      def check(role, suspect, object=nil)
        @backend[collection].find(make_doc(role, suspect, object)).empty? == false or begin
          object && !object.is_a?(Class) ? check(role, suspect, object.class) : false
        end
      end

      def delete(role, suspect, object=nil)
        @backend[collection].remove(make_doc(role, suspect, object)
      end

      def clear
        @backend[collection].remove
      end
      
      private
      
      def make_doc(role, suspect, object)
        { "suspect" => suspect_id(suspect), "role" => pack(role.to_s, object) }
      end
    end # Mongo
  end # Store
end # Aclatraz
