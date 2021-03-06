require 'spec_helper'

describe Slipcover::Database, 'functional to the Slipcover database' do
  let(:database) { Slipcover::Database.new(name, server) }
  let(:name) { 'database_name' }
  let(:server) { Slipcover::Server.new(File.dirname(__FILE__) + "/support/slipcover.yml", 'development') }
  let(:database_url) { "#{database.server.url}/database_name_development" }

  def ensure_database
    delete_database
    RestClient.put(database_url, {}.to_json, {:content_type => :json, :accept => :json})
  end

  def delete_database
    RestClient.delete(database_url) rescue nil
  end

  after do
    delete_database
  end

  describe '#info' do
    before do
      ensure_database
    end

    it "return information about the database" do
      info = database.info
      info.should be_a(Hash)
      info.keys.should include(:doc_count)
    end
  end

  describe "#create" do
    context 'database does not exist' do
      before do
        delete_database
      end

      it 'creates the database' do
        database.create
        database.info.keys.should include(:doc_count)
      end
    end

    context 'database already exists' do
      before do
        ensure_database
      end

      it 'passes silently' do
        database.create
      end
    end
  end

  describe "#delete" do
    context 'database exists' do
      before do
        ensure_database
      end

      it "deletes the database" do
        database.delete.should == true

        expect {
          database.info
        }.to raise_error( Slipcover::HttpAdapter::DBNotFound )
      end
    end

    context 'database does not exist' do
      before do
        delete_database
      end

      it "returns false" do
        database.delete.should == false
      end
    end
  end
end
