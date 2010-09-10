module Aclatraz
  class ACL
    class Action
      attr_reader :permissions
      
      def initialize(parent, &block)
        @parent = parent
        @permissions = Dictionary.new
        instance_eval(&block)
      end

      def allow(permission)
        @permissions[permission] = true
      end
    
      def deny(permission)
        @permissions[permission] = false
      end
      
      def all
        true
      end
      
      def on(*args, &block)
        @parent.on(*args, &block)
      end
    end    
    
    attr_reader :actions
    
    def initialize(&block)
      @actions = {}
      on(:_, &block)
    end
    
    def permissions
      @actions[:_] ? @actions[:_].permissions : Dictionary.new
    end
    
    def [](action)
      @actions[action]
    end
    
    def on(action, &block)
      raise ArgumentError, "No block given" unless block_given?
      if @actions.key?(action)
        @actions[action].instance_eval(&block)
      else
        @actions[action] = Action.new(self, &block)
      end
    end
  end
end
