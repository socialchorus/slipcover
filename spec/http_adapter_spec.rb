require 'spec_helper'

describe Slipcover::HttpAdapter do
  let(:adapter) { Slipcover::HttpAdapter.new }


  describe '#get' do
    let(:response) { {}.to_json }

    before do
      RestClient.stub(:get).and_return(response)
    end

    it "should package up data into a query string" do
      RestClient.should_receive(:get).with('http://url.com?foo=bar', anything).and_return(response)
      adapter.get('http://url.com', {foo: 'bar'})
    end
  end

  describe '#delete' do
    let(:response) { {}.to_json }

    before do
      RestClient.stub(:delete).and_return(response)
    end

    it "should package up data into a query string" do
      RestClient.should_receive(:delete).with('http://url.com?foo=bar', anything).and_return(response)
      adapter.delete('http://url.com', {foo: 'bar'})
    end
  end
end
