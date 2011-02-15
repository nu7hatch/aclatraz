module Aclatraz
  module Helpers
    # Given underscored word, returns camelized version of it. 
    #
    #   camelize(foo_bar_bla) # => "FooBarBla"
    def camelize(string)
      string.split('_').map {|word| word.capitalize}.join
    end
    
    # If given object is kind of string or integer then returns it, otherwise
    # it tries to return its ID.
    def suspect_id(suspect)
      suspect.is_a?(String) || suspect.is_a?(Integer) ? suspect.to_s : suspect.id.to_s
    end
    
    # Unpack given permission data.
    def unpack(data)
      data.to_s.split("/")
    end
    
    # Pack given permission data.
    #
    #   pack(foo)               # => "foo"
    #   pack(foo, "FooClass")   # => "foo/FooClass"
    #   pack(foo, FooClass.new) # => "foo/FooClass/{foo_object_ID}"
    def pack(role, object=nil)
      case object
      when nil
        data = [role]
      when Class 
        data = [role, object.name]
      else 
        data = [role, object.class.name, object.id]
      end
      data.join("/")
    end
  end # Helpers
end # Aclatraz
