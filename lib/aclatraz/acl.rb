module Aclatraz
  class ACL
    class Permissions
      attr_reader :allowed
      attr_reader :denied

      def initialize(&block)
        @allowed, @denied = [], []
        instance_eval(&block)
      end

      def allow(permission)
        @allowed << permission
      end
    
      def deny(permission)
        @denied << permission
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
    
    def deny
      @actions[:_].denied
    end
    
    def on(action, &block)
      if @actions.key?(action)
        @actions[action] = Permissions.new(&block)
      else
        @actions[action].instance_eval(&block)
      end
    end
  end
end
