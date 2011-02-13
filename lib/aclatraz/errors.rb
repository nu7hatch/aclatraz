module Aclatraz
    # Raised when suspect don't have permission to execute action
  class AccessDenied < Exception; end 
  
  # Raised when suspect specified in guarded class is invalid
  class InvalidSuspect < ArgumentError; end
  
  # Raised when invalid permission is set in ACL
  class InvalidPermission < ArgumentError; end
  
  # Raised when try to initialize invalid datastore
  class InvalidStore < ArgumentError; end
  
  # Raised when datastore is not initialized when managing permission
  class StoreNotInitialized < Exception; end
  
  # Raised when try to guard class without any ACL defined
  class UndefinedAccessControlList < Exception; end
end # Aclatraz
