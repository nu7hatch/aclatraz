module Aclatraz
  module Helpers
    # Pack given permission data.
    #
    #   pack(10)               # => "10"
    #   pack(10, "FooClass")   # => "10/FooClass"
    #   pack(10, FooClass.new) # => "10/FooClass/{foo_object_ID}"
    def pack(owner, object=nil)
      case object
      when nil
        "#{owner}"
      when Class 
        "#{owner}/#{object.name}"
      else 
        "#{owner}/#{object.class.name}/#{object.id}"
      end
    end
    
    # Given underscored word, returns camelized version of it. 
    #
    #   camelize(foo_bar_bla) # => "FooBarBla"
    def camelize(str)
      str.split('_').map {|w| w.capitalize}.join
    end
  end # Helpers
end # Aclatraz
