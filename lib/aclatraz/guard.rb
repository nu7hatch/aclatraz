module Aclatraz
  module Guard
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end
    
    module ClassMethods
      attr_reader :acl_suspect
      attr_reader :acl_permissions
      
      def suspects(name, &block)
        @acl_suspect = name
        @acl_permissions = ACL.new(&block)
      end
      alias_method :access_control, :suspects
    end
    
    module InstanceMethods
      def current_suspect
        case self.class.acl_suspect
        when Symbol
          @current_suspect ||= send(self.class.acl_suspect)
        when String
          @current_suspect ||= instance_variable_get("@#{self.class.acl_suspect}")
        else
          @current_suspect ||= self.class.acl_suspect     
        end
      end
      
      def guard!(*actions)
        if current_suspect.respond_to?(:acl_suspect?)
          actions.unshift(:_)
          authorized = false
          permissions = Dictionary.new
          
          actions.each do |action| 
            self.class.acl_permissions.actions[action].permissions.each_pair do |key, value|     
              permissions.delete(key)
              permissions.push(key, value)
            end
          end
          
          puts permissions.inspect
          
          permissions.each do |permission, allow|
            has_permission = check_permission(permission)
            if permission == true
              authorized = allow ? true : false
              next
            end
            if allow
              authorized ||= has_permission  
            else
              authorized = false if has_permission
            end
          end
          
          raise Aclatraz::AccessDenied unless authorized
          true
        else
          raise Aclatraz::InvalidSuspect
        end
      end
      alias_method :authorize!, :guard!
      
      def check_permission(permission)
        case permission
        when String, Symbol, true
          current_suspect.has_role?(permission)
        when Hash
          permission.each do |role, object| 
            case object
            when String
              object = instance_variable_get("@#{object}") 
            when Symbol
              object = send(object)
            end
            return true if current_suspect.has_role?(role, object)
          end
          false
        else
          raise Aclatraz::InvalidPermission
        end
      end
    end
  end
end
