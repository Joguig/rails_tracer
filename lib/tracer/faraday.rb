require 'active_support'

class Tracer::Faraday < Tracer::Base
  SERVICE_REGEX = /request\.faraday\.([^.]*)/
  def self.init
    ActiveSupport::Notifications.subscribe(/request.faraday/) do |name, start, finish, _, env|
      if transaction_id
        service_name = SERVICE_REGEX.match(name)
        if service_name
          @service = $1

          # Hack because Rails reports these incorrectly sometimes
          if /jax/.match(env[:url].to_s)
            @service = "jax"
          elsif /usher/.match(env[:url].to_s)
            @service = "usher"
          end

          data = {method: env[:method], url: env[:url].to_s, status: env[:status].to_s}
          if env[:status] == 0 || env[:status] > 500
            data.merge!({error: env[:status].to_s})
          end

          call(start, finish, data)
        end
      end
    end
  end
end
