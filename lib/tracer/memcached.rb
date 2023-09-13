require 'active_support'

class Tracer::Memcached < Tracer::Base
  @service = "memcached"

  def self.init
    ActiveSupport::Notifications.subscribe(/cache_/) do |name, start, finish, test, env|
      if transaction_id
        type = name.start_with?('cache_set') ? :set : :get
        data = {type: type, key: env[:key]}
        data.merge!(error_data(env))

        call(start, finish, data)
      end
    end
  end
end
