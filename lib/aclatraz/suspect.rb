module Aclatraz
  module Suspect
    class Roles
      # These suffixes will be ignored while checking permission.
      ACL_ROLE_SUFFIXES = /(_(of|at|on|by|for|in))?\Z/
      
      # Permissions will be checked for this object. 
      attr_reader :suspect
  
      def initialize(suspect) # :nodoc:
        @suspect = suspect
      end
      
      # Check if current object has assigned given role.
      #
      # ==== Examples
      #
      #   suspect.roles.assign(:foo)
      #   suspect.roles.has?(:foo) # => true
      #   suspect.roles.has?(:bar) # => false
      def has?(role, object=nil)
        Aclatraz.store.check(role.to_s.gsub(ACL_ROLE_SUFFIXES, ''), suspect, object)
      end
      alias_method :check?, :has?
      
      # Assigns given role to current object. 
      #
      # ==== Examples
      #
      #   suspect.roles.has?(:foo) # => false
      #   suspect.roles.assign(:foo)
      #   suspect.roles.has?(:foo) # => true
      def assign(role, object=nil)
        Aclatraz.store.set(role.to_s.gsub(ACL_ROLE_SUFFIXES, ''), suspect, object)
      end 
      alias_method :add, :assign
      alias_method :append, :assign
      
      # Removes given role from current object.
      #
      # ==== Examples
      #
      #   suspect.roles.assign(:foo)
      #   suspect.roles.has?(:foo) # => true
      #   suspect.roles.delete(:foo)
      #   suspect.roles.has?(:foo) # => false
      def delete(role, object=nil)
        Aclatraz.store.delete(role.to_s.gsub(ACL_ROLE_SUFFIXES, ''), suspect, object)
      end
      alias_method :remove, :delete
      
      # Returns list of roles assigned to current object. 
      #
      # ==== Examples
      #
      #   suspect.roles.assign(:foo)
      #   suspect.roles.assign(:bar)
      #   suspect.roles.all # => ["foo", "bar"]
      def all
        Aclatraz.store.roles(suspect)
      end
      alias_method :list, :all
      
      # Clears all roles assigned to the current object and returns the list.
      #
      # ==== Examples
      #
      #   suspect.roles.assign(:foo)
      #   suspect.roles.assign(:bar)
      #   suspect.roles.clear # => ["foo", "bar"]
      #   suspect.roles.has?(:foo) # => false
      #   suspect.roles.has?(:bar) # => false
      def clear
        all.each do |role|
          delete(role)
        end
      end
      alias_method :delete_all, :clear
      alias_method :remove_all, :clear
      
      # Enumerates all objects on which explicit permissions for the given role 
      # have been granted via suspect.roles.add(:role, object)
      #
      # This method does not return the objects that permissions were granted for to avoid
      # costly single retrieval of potentially hundreds of objects from a store.
      #
      # ==== Examples
      #
      #   suspect.roles.add(:foo, 12)
      #   suspect.roles.add(:foo, 15)
      #   suspect.roles.add(:bar, 3)
      #   suspect.roles.permissions(:foo) # => [12, 15]
      #
      def permissions(role)
        Aclatraz.store.permissions(role, suspect)
      end
      
    end # Roles
  
    class SemanticRoles
      class Base < Aclatraz::Suspect::Roles
        # Role name can have following formats:
        ROLE_FORMAT = /(_(of|at|on|by|for|in))?(\?|\!)\Z/
    
        # Check if specified suspect have assigned given role. If true, then 
        # given block will be executed. 
        def reader(*args, &blk)
          authorized = has?(*args)
          blk.call if authorized && block_given?
          authorized
        end
        
        # Assigns given role to specified suspect.  
        def writer(*args)
          assign(*args)
        end

        # Provides syntactic sugars for checking and assigning roles. 
        #
        # ==== Examples
        #
        # checking permissions...
        #   manager?
        #   owner_of?(object)
        #   manager_of?(Class)
        #   responsible_for?(object)
        #
        # writing permissions...   
        #   responsible_for!(object)
        #   manager!
        #   
        # ==== Accepted method names
        #
        # * role_name
        # * role_name<strong>_of</strong>
        # * role_name<strong>_at</strong>
        # * role_name<strong>_by</strong>
        # * role_name<strong>_in</strong>
        # * role_name<strong>_on</strong>
        # * role_name<strong>_for</strong>
        
        def method_missing(meth, *args, &blk)
          meth = meth.to_s
          if meth =~ ROLE_FORMAT
            write = meth[-1].chr == "!" 
            role  = meth.gsub(ROLE_FORMAT, '')
            args.unshift(role.to_sym)
            write ? writer(*args) : reader(*args, &blk)
          else
            # super doesn't work here, so...
            raise NoMethodError, "undefined local variable or method method `#{meth}' for #{inspect}:#{self.class.name}"
          end
        end
      end # Base
      
      class Yes < Base
        # nothing to do, only syntactic sugar...
      end # Yes
      
      class Not < Base
        # Deletes given role from suspected object.  
        def writer(*args)
          delete(*args)
        end
        
        # Check if specified suspect have assigned given role. If don't, then 
        # given block will be executed and +true+ returned. 
        def reader(*args, &blk)
          authorized = has?(*args)
          blk.call if !authorized && block_given?
          !authorized
        end
      end # Not
    end # SemanticRoles
  
    def self.included(base) # :nodoc:
      base.send :include, InstanceMethods
    end
    
    module InstanceMethods
      def acl_suspect? # :nodoc:
        true
      end
      
      # Allows to manage roles assigned to current object.
      #
      # ==== Examples
      #
      #   roles.assign(:foo)
      #   roles.has?(:foo) # => true
      #   roles.delete(:foo)
      #   roles.has?(:foo) # => false
      #   roles.assign(:foo, ClassName)
      #   roles.assign(:foo, object)
      def roles
        @roles ||= Roles.new(self)
      end
      
      # Port to semantic roles management. 
      #
      # ==== Examples
      #
      #   roles.is.foo!                   # equivalent to `roles.assign(:foo)`
      #   roles.is.foo?                   # => true
      #   roles.is.manager_of!(ClassName) # equivalent to `roles.assign(:manager, ClassName)`
      #   rikes.is.manager_of?(ClassName) # => true
      def is
        @acl_is ||= SemanticRoles::Yes.new(self)
      end
      
      # Port to semantic roles management. 
      #
      # ==== Examples
      #
      #   roles.is_not.foo!               # equivalent to `roles.delete(:foo)`
      #   roles.is.foo?                   # => false
      #   roles.is_not.foo?               # => true
      #   roles.is.manager_of!(ClassName) # equivalent to `roles.delete(:manager, ClassName)`
      #   roles.is.manager_of?(ClassName) # => flase
      def is_not
        @acl_is_not ||= SemanticRoles::Not.new(self)
      end
    end # InstanceMethods
  end # Suspect
end # Aclatraz
