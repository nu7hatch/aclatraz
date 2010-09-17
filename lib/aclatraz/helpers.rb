module Aclatraz
  module Helpers
    # Given underscored word, returns camelized version of it. 
    #
    #   camelize(foo_bar_bla) # => "FooBarBla"
    def camelize(str)
      str.split('_').map {|w| w.capitalize}.join
    end
    
    # If given object is kind of string or integer then returns it, otherwise
    # it tries to return its ID.
    def member_id(member)
      member.is_a?(String) || member.is_a?(Integer) ? member.to_s : member.id.to_s
    end
  end # Helpers
end # Aclatraz
