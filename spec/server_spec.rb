require 'spec_helper'

describe Slipcover::Server do
  let(:server) { Slipcover::Server.new(config_path, env) }
  let(:config_path) { File.dirname(__FILE__) + "/support/slipcover.yml" }
  let(:env) { 'development' }

  context "when the host is a local address" do
    describe "#url" do
      it 'returns the right url' do
        server.url.should == "127.0.0.1:5984"
      end
    end
  end

  context "when the host is a remote address" do
    let(:env) { 'production' }
    describe "#url" do
      it 'returns the right url' do
        server.url.should == "username:password@socialcoders.couchserver.com"
      end
    end
  end
end
