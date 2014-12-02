require 'spec_helper'

describe Slipcover::Query do
  let(:query) { Slipcover::Query.new(design_document, :by_name) }
  let(:design_document) { Slipcover::DesignDocument.new(database_name, view_dir) }

  let(:database_name)   { 'my_database_name' }
  let(:view_dir)        { support_dir + "/slipcover_views" }
  let(:support_dir)     { File.dirname(__FILE__) + "/support" }

  before do
    db = Slipcover::Database.new(database_name)
    db.delete
    db.create

    design_document.save

    Slipcover::Document.new(database_name, {name: 'Deepti'}).save
    Slipcover::Document.new(database_name, {name: 'Fito'}).save
    Slipcover::Document.new(database_name, {name: 'Kane'}).save
    Slipcover::Document.new(database_name, {animal: 'gerbil'}).save
  end

  after do
    db = Slipcover::Database.new(database_name)
    db.delete
  end

  describe '#all' do
    it 'returns all the documents that match the index/view' do
      results = query.all(include_docs: true)
      results.size.should == 3
      results.map {|doc| doc[:name] }.should =~ ['Deepti', 'Fito', 'Kane']
    end

    context 'with options' do
      context 'with key' do
        it "returns only the related records" do
          results = query.all(key: 'Deepti', include_docs: true)
          results.size.should == 1
          results.first[:name].should == 'Deepti'
        end
      end

      it "filters by keys" do
        results = query.all(keys: ["Deepti", "Fito"], include_docs: true)
        results.map {|doc| doc[:name] }.should =~ ["Deepti", "Fito"]
      end

      # this required POSTing to a Couch view because the URL is too long when
      # there are a lot of keys
      it "can filter by a lot of keys" do
        results = query.all(keys: ["Deepti", "Fito",
                                   *999.times.map { |i| "Vlad#{i}" }],
                            include_docs: true)
        results.map {|doc| doc[:name] }.should =~ ["Deepti", "Fito"]
      end

      context 'with a startkey and endkey' do
        it "return the range of docs" do
          results = query.all(startkey: 'Da', endkey: 'Fz', include_docs: true)
          results.size.should == 2
          results.map { |doc| doc[:name] }.should =~ ['Deepti', 'Fito']
        end
      end

      context "when the key contains special characters" do
        it "can be found" do
          Slipcover::Document.new(database_name, {name: "blah&"}).save
          results = query.all(key: "blah&", include_docs: true)
          results.first[:name].should == "blah&"
        end
      end
    end
  end
end
