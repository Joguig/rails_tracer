require 'spec_helper'
require_relative 'shared'

describe Tracer::Rails do
  include_context 'shared'

  describe :trace_request do
    it 'sends two traces' do
      Request = Struct.new(:remote_ip, :env, :original_url)
      request = Request.new("1.1.1.1", {'HTTP_REFERER' => 'twitch.tv', 'FOO' => 'BAR'}, "/testpage")
      data = {ip: '1.1.1.1', headers: 'REFERER: twitch.tv', url: '/testpage'}

      expect_trace(socket, {S: 'rails', K: 3, R: '.0', D: data})
      expect_trace(socket, {S: 'rails', K: 4, R: '.1', D: {}})

      Tracer::Rails.trace_request(request) {}
    end
  end
end
