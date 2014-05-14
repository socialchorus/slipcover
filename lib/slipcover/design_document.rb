module Slipcover
  class DesignDocument
    attr_reader :database_name, :name, :view_dir

    def initialize(database_name, name, view_dir=nil)
      @database_name = database_name
      @name = name
      @view_dir = view_dir || Slipcover::Config.view_dir
    end

    def document
      @document ||= Document.new(database_name, {
        id: document_id,
        language: 'javascript',
        views: views
      })
    end

    delegate :url, :attributes, :id, :rev, :delete, :database,
      to: :document

    def fetch
      document.fetch
      document.attributes[:views].symbolize_keys!
      document.attributes[:views].each {|key, hash| document.attributes[:views][key] = hash.symbolize_keys!}
      document
    end

    def save
      document.save
    rescue HttpAdapter::ConflictError
      document.fetch
      document[:views] = views
      document.save
    end

    def document_id
      "_design/#{name}"
    end

    def [](key)
      document[:views][key]
    end

    def views
      Dir.entries(view_dir).inject({}) do |hash, path|
        if !path.match(/\./)
          dir = view_dir + "/" + path
          hash[path.to_sym] ||= {}
          hash[path.to_sym][:map] = File.read(dir + "/map.js")
          hash[path.to_sym][:reduce] = File.read(dir + "/reduce.js") if File.exist?(dir + "/reduce.js")
        end
        hash
      end
    end
  end
end
