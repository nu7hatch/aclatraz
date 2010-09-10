module Aclatraz
  class ACL
    class Action
      attr_reader :allowed
      attr_reader :denied

      def initialize(parent, &block)
        @parent = parent
        @allowed, @denied = [], []
        instance_eval(&block)
      end

      def allow(permission)
        @allowed << permission
      end
    
      def deny(permission)
        @denied << permission
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
    
    def allowed
      @actions[:_].allowed
    end
    
    def denied
      @actions[:_].denied
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
