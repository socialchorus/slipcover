require 'spec_helper'

describe Slipcover::DesignDocument do
  let(:document) { Slipcover::DesignDocument.new(database_name, name, view_dir) }
  let(:database_name) { 'design_me' }
  let(:database) { Slipcover::Database.new(database_name) }
  let(:name) { 'designation' }
  let(:view_dir) { support_dir + "/slipcover_views" }

  let(:support_dir) { File.dirname(__FILE__) + "/support" }
  let(:map_function) { File.read(view_dir + "/by_name/map.js") }

  before do
    database.delete
    database.create
  end

  it "defaults to javascript as a language" do
    document.attributes[:language].should == 'javascript'
  end

  it "has the right url" do
    document.url.should == "#{database.url}/_design/designation"
  end

  describe 'views' do
    it "finds them via the mapping of the name to the view directory" do
      document[:by_name][:map].should == map_function
    end
  end

  describe '#save' do
    context "when the design document does not yet exist" do
      it "saves it and delegates good stuff to it" do
        document.save
        document.fetch
        document[:by_name][:map].should == map_function
        document.id.should_not be_nil
        document.rev.should_not be_nil
      end
    end

    context 'when the design document already exists' do
      it "updates it without raising an error" do
        document.save

        duplicate_document = Slipcover::DesignDocument.new(database_name, name, view_dir)

        duplicate_document.save
        duplicate_document.rev.should_not be_nil

        # expect { duplicate_document.save }.not_to raise_error
      end
    end
  end
end
