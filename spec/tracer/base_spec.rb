require 'spec_helper'
require_relative 'shared'

describe Tracer::Base do
  include_context 'shared'

  describe :send_trace do
    describe 'without transaction id' do
      let(:transaction_id) { nil }
      let(:subtransaction_id) { nil }

      it 'sends a trace without transaction id' do
        expect_trace(socket, {K: 1, S: 'unknown', D: {}}, ids: false)
        Tracer::Base.send_trace(:connect)
      end
    end

    describe 'with transaction id' do
      it 'sends a trace with transaction id' do
        expect_trace(socket, {K: 1, S: 'unknown', D: {}})
        Tracer::Base.send_trace(:connect)

        expect_trace(socket, {K: 1, S: 'unknown', R: '.12', D: {}})
        Tracer::Base.send_trace(:connect)
      end
    end

    describe 'no socket' do
      let(:socket) { nil }

      it 'does nothing' do
        expect{ Tracer::Base.send_trace(:connect) }.not_to raise_error
      end
    end

    describe 'socket error' do
      it "doesn't raise an error" do
        socket.stub(:send).and_raise(Errno::ETIMEDOUT)
        expect{ Tracer::Base.send_trace(:connect) }.not_to raise_error
      end
    end
  end
end
