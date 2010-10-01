module Aclatraz
  module Store
    autoload :Redis,        'aclatraz/store/redis'
    autoload :Riak,         'aclatraz/store/riak'
    autoload :Cassandra,    'aclatraz/store/cassandra'
    #autoload :Memcached,    'aclatraz/store/memcached'
    #autoload :TokyoCabinet, 'aclatraz/store/tokyocabinet'
  end # Store
end # Aclatraz
