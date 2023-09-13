class Tracer::Rails < Tracer::Base
  @service = "rails"

  class << self
    def init(opts)
      super
      send_trace(:connect)
    end

    def trace_request(request)
      route = request.env['action_dispatch.request.path_parameters']
      thumb = "#{route[:controller]}##{route[:action]}"
      rails_data = {
        ip: request.remote_ip,
        headers: headers(request),
        url: request.original_url,
        thumb: thumb
      }

      ids = {}
      if request.env['TRACE-ID']
        ids[:transaction_id] = request.env['TRACE-ID'].to_i
        ids[:subtransaction_id] = request.env['TRACE-SUBID'].delete('.').to_i
      end

      super(ids) do
        transaction(data: rails_data) do
          yield
        end
      end
    end

    def headers(request)
      request.env.select {|k, v| k.start_with? 'HTTP_'}.
        map {|header| "#{header[0].sub(/^HTTP_/, '')}: #{header[1]}"}.
        join("\n")
    end
  end
end
