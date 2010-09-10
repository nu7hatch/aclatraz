module Aclatraz
  module Helpers
    def pack(prefix, object=nil)
      case object
      when nil
        "#{prefix}"
      when Class 
        "#{prefix}/#{object.name}"
      else 
        "#{prefix}/#{object.class.name}/#{object.id}"
      end
    end
    
    def camelize(str)
      str.split('_').map {|w| w.capitalize}.join
    end
  end
end
