require 'active_support'

class Tracer::Mongo < Tracer::Base
  @service = "mongo"

  def self.init
    ActiveSupport::Notifications.subscribe(/mongo\./) do |name, start, finish, _, env|
      type = name.sub(/mongo\./, "")
      if transaction_id
        data = env.merge({type: type})
        data.merge!(error_data(env))
        call(start, finish, data)
      end
    end
  end
end
