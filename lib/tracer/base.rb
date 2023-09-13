require 'active_support/all'
require 'rails'
require 'oj'
require 'timeout'

module Tracer
  class Base
    MAX_TRANSACTION_ID = 2**64

    KINDS = {
      admin: 0,
      connect: 1,
      event: 2,
      transaction_start: 3,
      transaction_end: 4,
      call_start: 5,
      call_end: 6
    }

    RECONNECT_PROBABILITY = 1/2000.0

    @service = "unknown"
    @@host = nil
    @@pid = nil
    @@collect_host = nil
    @@collect_port = nil
    @@socket = nil

    class << self
      def init(opts)
        @@host = opts[:host]
        @@pid = opts[:pid]
        @@collect_host = opts[:collect_host]
        @@collect_port = opts[:collect_port]

        connect_socket
      end

      def connect_socket
        return if @@socket || !@@collect_host || !@@collect_port

        begin
          timeout(0.5.second) do
            @@socket = TCPSocket.new @@collect_host, @@collect_port
          end
        rescue => e
          ::Rails.logger.error "Could not connect to trace: #{e}"
        end
      end

      def send_trace(kind, opts={})
        if !@@socket && rand() < RECONNECT_PROBABILITY
          connect_socket
        end

        return unless @@socket

        msg = trace_message(kind, opts)

        begin
          @@socket.sendmsg_nonblock(msg)
        rescue SystemCallError => e
          ::Rails.logger.error "Disconnecting from trace: #{e}"
          @@socket = nil
          connect_socket
          if @@socket
            @@socket.sendmsg_nonblock(trace_message(:connect, opts))
            @@socket.sendmsg_nonblock(msg)
          end
        end
      end

      def trace_message(kind, opts)
        trace = {
          K: KINDS[kind],
          P: @@pid,
          M: @@host,
          S: @service,
          T: nanosecs(opts[:time] || Time.now),
          D: opts[:data] || {}
        }

        if transaction_id
          trace.merge!({
            I: transaction_id,
            R: ".#{increment_subtransaction_id}"
          })
        end

        "#{Oj.dump(trace)}\n"
      end

      def transaction(opts={})
        send_trace(:transaction_start, opts)

        yield

        send_trace(:transaction_end)
      end

      def trace_request(ids={})
        Thread.current[:transaction_id] = ids[:transaction_id] || SecureRandom.random_number(MAX_TRANSACTION_ID)
        Thread.current[:subtransaction_id] = ids[:subtransaction_id] || 0

        yield

        Thread.current[:transaction_id] = nil
        Thread.current[:subtransaction_id] = nil
      end

      def call(start, finish, data)
        send_trace(:call_start, time: start, data: data)
        send_trace(:call_end, time: finish)
      end

      def error_data(payload)
        if payload.key?(:exception) && payload[:exception][1]
          return {error: payload[:exception][1].to_s.squish}
        end

        return {}
      end

      private

      def transaction_id
        Thread.current[:transaction_id]
      end

      def increment_subtransaction_id
        id = Thread.current[:subtransaction_id]
        Thread.current[:subtransaction_id] += 1
        id
      end

      def nanosecs(time)
        ("#{time.to_i}%09d" % time.nsec).to_i
      end
    end
  end
end
