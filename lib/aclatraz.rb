
module Aclatraz
  module Helpers
    def pack(owner, object=nil)
      case object
      when nil
        "#{owner.id}"
      when Class 
        "#{owner.id}/#{object.name}"
      else 
        "#{owner.id}/#{object.class.name}/#{object.id}"
      end
    end
  end
end
