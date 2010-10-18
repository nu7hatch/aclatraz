module Aclatraz
  class ACL
    class Action
      # All permissions defined in this action.  
      attr_reader :permissions
      
      def initialize(parent, &block) 
        @parent = parent
        @permissions = Dictionary.new {|h,k| h[k] = false}.merge(parent.permissions)
        instance_eval(&block) if block_given?
      end

      # Add permission for objects which have given role. 
      #
      # ==== Examples
      #
      #   allow :admin
      #   allow :owner_of => "object"
      #   allow :owner_of => :object
      #   allow :owner_of => object
      #   allow :manager_of => ClassName
      #   allow all
      def allow(permission)
        @permissions[permission] = true
      end
    
      # Add permission for objects which don't have given role. 
      #
      # ==== Examples
      #
      #   deny :admin
      #   deny :owner_of => "object"
      #   deny :owner_of => :object
      #   deny :owner_of => object
      #   deny :manager_of => ClassName
      #   deny all
      def deny(permission)
        @permissions[permission] = false
      end
      
      # Syntactic sugar for aliasing all permissions.
      #
      # ==== Examples
      #  
      #   allow all
      #   deny all
      def all
        true
      end
      
      # See <tt>Aclatraz::ACL#on</tt>.
      def on(*args, &block)
        @parent.on(*args, &block)
      end
      
      def clone(parent) # :nodoc:
        self.class.new(parent)
      end
    end # Action
    
    # All actions defined in current ACL.
    attr_reader :actions
    
    # Current suspected object. 
    attr_accessor :suspect
    
    def initialize(suspect, &block)
      @actions = {}
      @suspect = suspect
      evaluate(&block) if block_given?
    end
    
    # Evaluates given block in default action.
    #
    # ==== Example
    #
    #   evaluate do 
    #     allow :foo
    #     deny :bar
    #     ...
    #   end
    def evaluate(&block)
      on(:_, &block)
    end
    
    # List of permissions defined in default action. 
    def permissions
      @actions[:_] ? @actions[:_].permissions : Dictionary.new {|h,k| h[k] = false}
    end
    
    # Syntactic sugar for actions <tt>actions[action]</tt>.
    def [](action)
      actions[action]
    end
    
    # Defines given action with permissions described in evaluated block.
    #
    # ==== Examples
    #
    #   suspects do 
    #     on :create do 
    #       deny all
    #       allow :admin
    #     end
    #     on :delete do 
    #       allow :owner_of => "object"
    #     end
    #   end 
    def on(action, &block)
      raise ArgumentError, "No block given!" unless block_given?
      if @actions.key?(action)
        @actions[action].instance_eval(&block)
      else
        @actions[action] = Action.new(self, &block)
      end
    end

    def clone(&block) # :nodoc:
      actions = Hash[*self.actions.map {|k,v| [k, v.clone(self)] }.flatten]
      cloned = self.class.new(suspect)
      cloned.instance_variable_set("@actions", actions)
      cloned.evaluate(&block)
      cloned
    end
  end # ACL
end # Aclatraz
