require 'active_record'
require 'active_support'

class Tracer::ActiveRecord < Tracer::Base
  @service = "sql"

  def self.init

    db_conf = Rails.configuration.database_configuration[Rails.env]
    @master = "#{db_conf["host"]}:#{db_conf["port"]}"
    LogSubscriber.attach_to :active_record
  end

  def self.call(start, finish, event)
    return unless transaction_id

    payload = event.payload
    data = {sql: payload[:sql]}
    if payload[:db_host]
      data[:db] = payload[:db_host] == @master ? :master : :slave
    end

    data.merge!(error_data(payload))

    super(start, finish, data)
  end

  class LogSubscriber < ActiveSupport::LogSubscriber
    def sql(event)
      Tracer::ActiveRecord.call(event.time, event.end, event)
    end
  end
end
