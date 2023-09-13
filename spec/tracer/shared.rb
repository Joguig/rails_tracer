require 'oj'
require 'socket'

shared_context 'shared' do
  class FakeSocket
    def sendmsg_nonblock(msg)

    end
  end

  let(:transaction_id) { 456 }
  let(:subtransaction_id) { 11 }
  let(:socket) { FakeSocket.new }

  before do
    TCPSocket.stub(:new) { socket }

    Tracer::Base.init(host: "host", pid: 123, collect_host: 'collect_host', collect_port: 888)

    Thread.current[:transaction_id] = transaction_id
    Thread.current[:subtransaction_id] = subtransaction_id

    SecureRandom.stub(:random_number).and_return(456)

    Tracer::Base.stub(:nanosecs).and_return(999)
  end

  after do
    Thread.current[:transaction_id] = nil
    Thread.current[:subtransaction_id] = nil
  end


  def expect_trace(socket, exp, opts={})
    exp = {P: 123, T: 999, M: "host"}.merge(exp)
    if opts[:ids] != false
      exp = {I: 456, R: '.11'}.merge(exp)
    end

    socket.should_receive(:sendmsg_nonblock) do |msg|
      expect(Oj.load(msg)).to eq(Oj.load(Oj.dump(exp)))
    end
  end
end
