require 'spec_helper'

describe Slipcover::Server do
  let(:server) { Slipcover::Server.new(config_path, env) }
  let(:config_path) { File.dirname(__FILE__) + "/support/slipcover.yml" }
  let(:env) { 'development' }
  let(:username) { 'username' }
  let(:password) { 'password' }

  before do
    ENV['COUCH_USERNAME'] = username
    ENV['COUCH_PASSWORD'] = password
  end

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

  context "configured credientials" do
    let(:env) { 'production' }
    let(:username) { 'Astronaut' }
    let(:password) { 'paddle-boarding' }

    before do
      ENV['COUCH_USERNAME'] = username
      ENV['COUCH_PASSWORD'] = password
    end

    describe "username" do
      it "gets it from the env" do
        server.username.should == username
      end
    end

    describe "password" do
      it "gets it from the env" do
        server.password.should == password
      end
    end
  end
end
