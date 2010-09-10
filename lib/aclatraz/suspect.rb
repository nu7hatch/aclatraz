module Aclatraz
  module Suspect
    class SemanticRoles
      class Base
        SUFFIXES = /_(of|at|on|by|for|in)(\?|\!)\Z/
    
        attr_reader :suspect
    
        def initialize(user)
          @suspect = suspect
        end
      end
      
      class Yes < Base
        def method_missing(meth, *args, &blk)
          if meth.to_s =~ SUFFIXES || meth.to_s =~ /(\?|\!)\Z/
            set = $2 == '!'
            role = meth.to_s.gsub(SUFFIXES, '').gsub(/\?\Z/, '')
            
            if set 
              suspect.assign_role!(*args.unshift(role))
            else
              authorized = suspect.has_role?(*args.unshift(role.to_sym))
              blk.call if authorized && block_given?
              authorized
            end
          else
            super meth, *args, &blk
          end
        end
      end
      
      class Not < Base
        def method_missing(meth, *args, &blk)
          if meth.to_s =~ SUFFIXES || meth.to_s =~ /(\?|\!)\Z/
            set = $2 == '!'
            role = meth.to_s.gsub(SUFFIXES, '').gsub(/\?\Z/, '')
            
            if set 
              suspect.delete_role!(*args.unshift(role))
            else
              authorized = suspect.has_role?(*args.unshift(role.to_sym))
              blk.call if !authorized && block_given?
              !authorized
            end
          else
            super meth, *args, &blk
          end
        end
      end
    end
  
    def self.included(base)
      base.send :include, InstanceMethods
    end
    
    module InstanceMethods
      def acl_suspect?
        true
      end
      
      def has_role?(role, object=nil)
        Aclatraz.store.check(role, self, object)
      end
      
      def assign_role!(role, object=nil)
        Aclatraz.store.set(role, self, object)
      end 
      
      def delete_role!(role, object=nil)
        Aclatraz.store.delete(role, self, object)
      end
      
      def roles
        Aclatraz.store.roles(self)
      end
      
      def is
        @acl_is ||= SemanticRolesYes.new(self)
      end
      
      def is_not
        @acl_is_not ||= SemanticRolesNot.new(self)
      end
    end
  end
end
