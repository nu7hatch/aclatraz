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
    end
    
    module InstanceMethods
      def current_suspect
        @current_suspect ||= case self.class.acl_suspect
        when Symbol, String
          instance_variable_get("@#{self.class.suspect_name}")
        else
          self.class.suspect_name     
        end
      end
      
      def guard!(*actions)
        if current_suspect.suspect?
          actions.unshift(:_)
          authorized = false
          permissions = {}
          actions.each {|action| permissions.merge!(acl_permissions.actions[action]) }
          
          permissions.each do |permission, allow|
            has_permission = check_permission(permission)
            authorized ||= allow ? has_permission : !has_permission
          end
          
          raise Aclatraz::AccessDenied unless authorized
          true
        else
          raise Aclatraz::InvalidSuspect
        end
      end
      
      def check_permission(permission)
        case permission
        when String, Symbol
          current_suspect.has_role?(permission)
        when Hash
          permission.each {|role, object| current_suspect.has_role?(role, object) }
        else
          raise Aclatraz::InvalidPermission
        end
      end
    end
  end
end
