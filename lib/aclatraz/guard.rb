module Aclatraz
  module Guard
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods  
    end
    
    module CommonMethods
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
          actions = [:_] if actions.empty?
          allowed, denied = [], []
          authorized = true
          
          actions.each do |action|
            allowed += acl_permissions.allowed
            denied  += acl_permissions.denied  
          end
          
          authorized |= allowed.any? {|permission| assert_permission(permission) }
          authorized |= denied.all? {|permission| !assert_permission(permission) }
          
          raise Aclatraz::AccessDenied unless authorized
        else
          raise Aclatraz::InvalidSuspect
        end
      end
      
      def assert_permission(permission)
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
    
    module ClassMethods
      include CommonMethods

      attr_reader :acl_suspect
      attr_reader :acl_permissions
      
      def suspects(name, &block)
        @acl_suspect = name
        @acl_permissions = ACL.new(&block)
      end
    end
    
    module InstanceMethods
      include CommonMethods
    end
  end
end
