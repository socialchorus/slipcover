require 'spec_helper'

describe Slipcover::Wrapper do
  let(:wrapper){ Slipcover::Wrapper.new({database_name: "test_database", view_name: "view"}) }

  describe "#lookup" do
    let(:query){ double(:query) }
    let(:design_document){ double(:doc, save:true) }
    before do
      Slipcover::DesignDocument.stub(:new).and_return(design_document)
    end

    it "makes a slipcover query" do
      Slipcover::Query.should_receive(:new).and_return(query)
      query.should_receive(:all).and_return([double(:thingy, attributes: true)])
      wrapper.lookup
    end

    context "database does not exist" do
      let(:database) { double('database', name: "thingy") }

      it "creates a database" do
        Slipcover::Query.should_receive(:new).and_return(query)
        query.should_receive(:all).ordered.and_raise(Slipcover::HttpAdapter::DBNotFound)
        query.should_receive(:all).ordered.and_return([double(:thingy, attributes: true)])

        Slipcover::Database.should_receive(:new).with(wrapper.database_name).and_return(database)
        database.should_receive(:create)
        wrapper.lookup
      end
    end

    context "design document does not exist" do
      it "saves the design document" do
        Slipcover::Query.should_receive(:new).and_return(query)
        query.should_receive(:all).ordered.and_raise(Slipcover::HttpAdapter::DocumentNotFound)
        query.should_receive(:all).ordered.and_return([double(:thingy, attributes: true)])

        Slipcover::DesignDocument.should_receive(:new).with(wrapper.database_name, wrapper.view_name, wrapper.view_dir).and_return(design_document)
        design_document.should_receive(:save)
        wrapper.lookup
      end
    end
  end

  describe "#initialize" do
    before(:each) do
      Slipcover::Config.stub(:view_dir).and_return("viewdir")
    end
    
    it "uses the default view_dir if none is passed in" do
      wrapper.view_dir.should_not == nil
      wrapper.view_dir.should == Slipcover::Config.view_dir
    end
  end
end
