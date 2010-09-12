module Aclatraz
  module Guard
    def self.included(base) # :nodoc:
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end
    
    module ClassMethods
      def acl_guard? # :nodoc:
        true
      end

      # Define access controll list for current class. 
      #
      # ==== Examples
      #
      #   suspects :foo do # foo method result will be treated as suspect
      #     deny all 
      #     allow :admin
      #     
      #     on :create do 
      #       allow :manager
      #       allow :manager_of => ClassName 
      #     end
      #
      #     on :edit do
      #       # only @object_name instance variable owner is allowed to edit it. 
      #       allow :owner_of => "object_name" 
      #     end 
      #   end 
      #
      #   # When called second time don't have to specify suspected object.  
      #   suspects do 
      #     allow :manager
      #   end
      def suspects(suspect=nil, &block)
        if acl = Aclatraz.acl[name]
          acl.suspect = suspect if suspect
          acl.evaluate(&block)
        elsif superclass.respond_to?(:acl_guard?) && acl = Aclatraz.acl[superclass.name]
          Aclatraz.acl[name] = acl.clone(&block)
        else
          Aclatraz.acl[name] = Aclatraz::ACL.new(suspect, &block)
        end
      end
      alias_method :access_control, :suspects
    end # ClassMethods
    
    module InstanceMethods
      # Returns suspected object.
      #
      # * when suspect name is a String then will return instance variable
      # * when suspect name is a Symbol then will be returned value of instance method
      # * otherwise suspect name will be treated as suspect object.  
      #
      # ==== Examples
      #
      #   class Bar
      #     suspects(:foo) { ... }
      #     def foo; @foo = Foo.new; end 
      #   end
      #   Bar.new.suspect.class # => Foo
      #
      #   class Bla
      #     suspects("foo") { ... }
      #     def init; @foo = Foo.new; end
      #   end 
      #   Bla.new.suspect.class # => Foo
      #
      #   class Spam
      #     foo = Foo.new
      #     suspects(foo) { ... }
      #   end
      #   Spam.new.suspect.class # => Foo
      #
      # You can also override this method in your protected class, and skip
      # passing arguments to +#suspects+ method, eg.
      #
      #   class Eggs
      #     suspects { ... }
      #     def suspect; @foo = Foo.new; end
      #   end
      def suspect
        @suspect ||= if acl = Aclatraz.acl[self.class.name]
          case acl.suspect
          when Symbol 
            send(acl.suspect)
          when String 
            instance_variable_get("@#{acl.suspect}")
          else 
            acl.suspect
          end
        end
      end
      
      # Check if current suspect have permissions to execute following code.
      # If suspect hasn't required permissions, or access for any of his roles 
      # is denied then raises +Aclatraz::AccessDenied+ error.
      def guard!(*actions)
        acl = Aclatraz.acl[self.class.name] or raise UndefinedAccessControlList, "No ACL for #{self.class.name} class"
        suspect.respond_to?(:acl_suspect?)  or raise Aclatraz::InvalidSuspect, "Invalid ACL suspect: #{suspect.inspect}"
        authorized = false
        permissions = Dictionary.new
        actions.unshift(:_)
        
        actions.each do |action| 
          acl.actions[action].permissions.each_pair do |key, value|     
            permissions.delete(key)
            permissions.push(key, value)
          end
        end
        
        permissions.each do |permission, allow|
          if permission == true
            authorized = allow ? true : false
            next
          end
          if allow
            authorized ||= assert_permission(permission)  
          else
            authorized = false if assert_permission(permission)
          end
        end
        
        authorized or raise Aclatraz::AccessDenied, "Access Denied"
        return true
      end
      alias_method :authorize!, :guard!
      
      # Check if current suspect has given permissions. 
      #
      # ==== Examples
      #
      #   assert_permission(:admin)
      #   assert_permission(:manager_of => ClassName)
      #   assert_permission(:owner_of => "object")
      def assert_permission(permission)
        case permission
        when String, Symbol, true
          suspect.roles.has?(permission)
        when Hash
          permission.each do |role, object| 
            if object.is_a?(String)
              object = instance_variable_get(object[0] ? "@#{object}" : object) 
            elsif object.is_a?(Symbol) 
              object = send(object)
            end
            return true if suspect.roles.has?(role, object)
          end
          return false
        else
          raise Aclatraz::InvalidPermission, "Invalid ACL permission: #{permission.inspect}"
        end
      end
    end # InstanceMethods
  end # Guard
end # Aclatraz
