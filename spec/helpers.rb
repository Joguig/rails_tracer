require 'rspec'

class FakeSocket
  def send(msg, flag)

  end
end

def expect_trace(socket, exp, opts={})
  exp = {P: 123, T: 999, M: "host"}.merge(exp)
  if opts[:ids] != false
    exp = {I: 456, R: '.11'}.merge(exp)
  end

  socket.should_receive(:send) do |msg, flag|
    expect(Oj.load(msg)).to eq(Oj.load(Oj.dump(exp)))
    expect(flag).to eq(0)
  end
end
