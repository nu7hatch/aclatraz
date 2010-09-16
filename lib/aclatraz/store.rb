module Aclatraz
  module Store
    autoload :Redis,        'aclatraz/store/redis'
    autoload :Riak,         'aclatraz/store/riak'
    #autoload :Memcached,    'aclatraz/store/memcached'
    #autoload :TokyoCabinet, 'aclatraz/store/tokyocabinet'
  end # Store
end # Aclatraz
