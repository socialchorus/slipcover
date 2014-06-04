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

  describe "response processing" do
    it "can digest json object result" do
      RestClient.stub(:get).and_return('{ "foo": "bar" }')
      adapter.get('http://url.com/db/something_returing_an_array').should == { foo: "bar" }
    end

    it "can digest json array result" do
      RestClient.stub(:get).and_return("[123, 456]")
      adapter.get('http://url.com/db/something_returing_an_array').should == [123, 456]
    end
  end

  describe "edge cases" do
    it "raises DBNotFound when the error reason is 'no_db_file'" do
      RestClient.stub(:post).and_raise(RestClient::ResourceNotFound.new('{"error": "not_found", "reason": "no_db_file"}'))
      expect do
        adapter.post('http://url.com/non_existing_db/document_to_update', {})
      end.to raise_error(Slipcover::HttpAdapter::DBNotFound)
    end

    it "raises NamedViewNotFound when the error reason is 'missing_named_view'" do
      RestClient.stub(:post).and_raise(RestClient::ResourceNotFound.new('{"error": "not_found", "reason": "missing_named_view"}'))
      expect do
        adapter.post('http://url.com/existing_db/non_existing_document', {})
      end.to raise_error(Slipcover::HttpAdapter::NamedViewNotFound)
    end

    it "raises DocumentNotFound when the error reason is 'missing'" do
      RestClient.stub(:post).and_raise(RestClient::ResourceNotFound.new('{"error": "not_found", "reason": "missing"}'))
      expect do
        adapter.post('http://url.com/existing_db/non_existing_document', {})
      end.to raise_error(Slipcover::HttpAdapter::DocumentNotFound)
    end

    # Need to test other exceptions!
  end
end
