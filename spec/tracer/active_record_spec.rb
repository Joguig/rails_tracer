require 'spec_helper'
require_relative 'shared'

describe Tracer::Rails do
  include_context 'shared'

  before do
    conn = Struct.new(:current_database).new('db_name')
    ActiveRecord::Base.stub(:connection) { conn }

    Tracer::ActiveRecord.init
  end

  describe :trace_request do
    it 'sends two traces' do
      data = {db: 'db_name', sql: 'SELECT 1;'}
      expect_trace(socket, {S: 'sql', K: 5, R: '.11', D: data})
      expect_trace(socket, {S: 'sql', K: 6, R: '.12', D: {}})

      event = Struct.new(:time, :end, :payload).new(123, 456, {sql: 'SELECT 1;'})
      Tracer::ActiveRecord::LogSubscriber.new.sql(event)

    end
  end
end
