module Aclatraz
  module Suspect
    class SemanticRoles
      class Base
        ROLE_SUFFIXES = /(_(of|at|on|by|for|in))?(\?|\!)\Z/
    
        attr_reader :suspect
    
        def initialize(suspect)
          @suspect = suspect
        end
      end
      
      class Yes < Base
        def method_missing(meth, *args, &blk)
          meth = meth.to_s
          if meth =~ ROLE_SUFFIXES
            setter = meth[-1].chr == "!" 
            role = meth.gsub(ROLE_SUFFIXES, '')
            if setter
              suspect.assign_role!(*args.unshift(role))
            else
              authorized = suspect.has_role?(*args.unshift(role.to_sym))
              blk.call if authorized && block_given?
              authorized
            end
          else
            # super doesn't work here, so...
            raise NoMethodError, "undefined local variable or method method `#{meth}' for #{inspect}:#{self.class.name}"
          end
        end
      end
      
      class Not < Base
        def method_missing(meth, *args, &blk)
          meth = meth.to_s
          if meth =~ ROLE_SUFFIXES
            deleter = meth[-1].chr == "!"
            role = meth.gsub(ROLE_SUFFIXES, '')
            if deleter 
              suspect.delete_role!(*args.unshift(role))
            else
              authorized = suspect.has_role?(*args.unshift(role.to_sym))
              blk.call if !authorized && block_given?
              !authorized
            end
          else
            raise NoMethodError, "undefined local variable or method method `#{meth}' for #{inspect}:#{self.class.name}"
          end
        end
      end
    end
  
    def self.included(base)
      base.send :include, InstanceMethods
    end
    
    module InstanceMethods
      ACL_ROLE_SUFFIXES = /(_(of|at|on|by|for|in))?\Z/
    
      def acl_suspect?
        true
      end
      
      def has_role?(role, object=nil)
        Aclatraz.store.check(role.to_s.gsub(ACL_ROLE_SUFFIXES, ''), self, object)
      end
      
      def assign_role!(role, object=nil)
        Aclatraz.store.set(role.to_s.gsub(ACL_ROLE_SUFFIXES, ''), self, object)
      end 
      
      def delete_role!(role, object=nil)
        Aclatraz.store.delete(role.to_s.gsub(ACL_ROLE_SUFFIXES, ''), self, object)
      end
      
      def roles
        Aclatraz.store.roles(self)
      end
      
      def is
        @acl_is ||= SemanticRoles::Yes.new(self)
      end
      
      def is_not
        @acl_is_not ||= SemanticRoles::Not.new(self)
      end
    end
  end
end
