# Tracer

Provides Trace support for Rails and ActiveRecord. Sends a trace for every request and AR query

Spec: http://git.internal.justin.tv/release/trace/README

# Usage

Initialize tracer
    Tracer::Rails.init(host: host, pid: pid, socket: socket)

Wrap process_action to trace rails requests
    def process_action(action, *args)
       Tracer::Rails.trace_request(request) do
         super
       end
    end

Initialize active record tracer to begin sending AR traces
    Tracer::ActiveRecord.init
