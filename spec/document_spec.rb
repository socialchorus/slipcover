require 'spec_helper'

describe Slipcover::Document, 'functional' do
  let(:document) { Slipcover::Document.new(database_name, attributes) }
  let(:database) { Slipcover::Database.new(database_name) }
  let(:database_name) { 'hello_database' }
  let(:attributes) {
    {
      type: 'foo',
      author: 'something'
    }
  }

  before do
    Slipcover::Config.server ||= Slipcover::Server.new(File.dirname(__FILE__) + "/support/slipcover.yml", 'development')
    database.create
  end

  after do
    database.delete
  end

  describe '#initialize' do
    let(:attributes) {
      {
        id: '298c2fd111c14633e445ef818b039ff3-us',
        rev: '2-298c2fd111c14633e445ef818b039ff3',
        type: 'foo',
        author: 'something'
      }
    }

    it "has an id" do
      document.id.should == attributes[:id]
    end

    it "has a rev" do
      document.rev.should == attributes[:rev]
    end
  end

  describe '#fetch' do
    before do
      document.save
      document.rev = nil
      document.attributes = {}
      document.fetch
    end

    it "should return all the attributes" do
      document.attributes[:type].should == 'foo'
      document.attributes[:author].should == 'something'
    end

    it "should update the rev" do
      document.fetch
      document.rev.should_not be_nil
    end

    it 'should raise an error if id does not exist' do
      document.id = nil
      expect{ document.fetch }.to raise_error
    end
  end

  describe '#save' do
    context 'when there is no id' do
      before do
        document.save
      end

      it "gets the id from the server response" do
        document.id.should_not be_nil
      end

      it "gets the rev from the server response" do
        document.rev.should_not be_nil
      end

      it 'should maintains its local attributes' do
        document.attributes[:type].should == 'foo'
        document.attributes[:author].should == 'something'
      end

      it "is stored in the database, and available" do
        expect {
          RestClient.get(document.url)
        }.not_to raise_error
        document.fetch
        document.attributes[:type].should == 'foo'
      end
    end

    context 'when there is an id passed in' do
      before do
        document.save
        document.attributes[:bar] = 'what?'
      end

      it 'gets a new revision' do
        original_rev = document.rev.clone
        document.save
        document.rev.should_not == original_rev
      end

      it 'updates the database' do
        document.save
        document.fetch
        document.attributes[:bar].should == 'what?'
      end

      it "does not create another document" do
        document.database.info[:doc_count].should == 1
      end
    end
  end

  describe '#delete' do
    context 'when the document is on the server' do
      before do
        document.save
        document[:_rev] = '_rev'
        document[:rev] = 'rev'
        document[:_id] = '_id'
        document[:id] = 'id'
      end

      it 'should delete the record from the database' do
        url = document.url
        document.delete
        expect {
          RestClient.get(url)
        }.to raise_error
      end

      it "should return true" do
        document.delete.should == true
      end

      it 'should clear the id and rev' do
        document.delete
        document.id.should be_nil
        document.rev.should be_nil
        document[:_id].should be_nil
        document[:id].should be_nil
        document[:_rev].should be_nil
        document[:rev].should be_nil
      end
    end

    context 'when the document is not on the sever' do
      it "should return false" do
        document.delete.should == false
      end
    end
  end
end
