module Slipcover
  class Wrapper
    attr_reader :database_name, :view_name, :view_dir

    def initialize(opts)
      @database_name = opts[:database_name]
      @view_name = opts[:view_name]
      @view_dir = opts[:view_dir] || Slipcover::Config.view_dir
    end

    def lookup(opts={})
      query.all(opts).map(&:attributes)
    rescue Slipcover::HttpAdapter::DBNotFound
      database.create
      retry
    rescue Slipcover::HttpAdapter::DocumentNotFound # no design document
      design_document.save
      retry
    end

    def query
      @query ||= Slipcover::Query.new(design_document, view_name)
    end

    def design_document
      @design_document ||= Slipcover::DesignDocument.new(database.name, view_name, view_dir)
    end

    def database
      @database ||= Slipcover::Database.new("#{database_name}")
    end
  end
end
