module Aclatraz
  module Store
    #autoload :Memcached,    'aclatraz/store/memcached'
    autoload :Redis,        'aclatraz/store/redis'
    #autoload :TokyoCabinet, 'aclatraz/store/tokyocabinet'
  
    class Base
      include Aclatraz::Helpers            
    end
  end
end
