module Slipcover
  class Query
    attr_reader :design_document, :view_name

    def initialize(design_document, view_name)
      @design_document = design_document
      @view_name = view_name
    end

    def http_adapter
      @http_adapter ||= HttpAdapter.new
    end

    delegate :get,
      to: :http_adapter

    def url
      "#{design_document.url}/_view/#{view_name}" # todo adapter takes opts and converts to query string
    end

    def all(opts={})
      get(url, repackage(opts))[:rows].map{|row| Document.new(database.name, row['doc'].symbolize_keys) }
    end

    def repackage(opts)
      opts = opts.dup

      opts.each do |key, value|
        opts[key] = escape(value) if escape_key?(key)
      end

      {include_docs: true}.merge(opts)
    end

    def database
      design_document.database
    end

    def escape(value)
      URI.escape(value.inspect)
    end

    def escape_key?(key)
      [:key, :keys, :startkey, :startkey_docid, :endkey, :endkey_docid, :stale].include?(key.to_sym)
    end
  end
end
