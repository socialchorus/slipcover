module Slipcover
  class Query
    attr_reader :design_document, :view_name

    def initialize(design_document, view_name)
      @design_document = design_document
      @view_name = view_name
    end

    def url
      "#{design_document.url}/_view/#{view_name}"
    end

    def all(opts={})
      do_http_request(opts)[:rows].map do |row|
        doc_data = opts[:include_docs] ? row["doc"] : row
        Document.new(database.name, doc_data.symbolize_keys)
      end
    end

    def database
      design_document.database
    end

    private

    # This is here because Cloudant doesn't support POST without supplying
    # `keys`.
    def do_http_request(opts)
      if opts.include?(:keys)
        opts_params, body_params = url_params_and_body(opts)
        url_with_qs = add_qs_to_url(url, repackage(opts_params))
        http_adapter.post(url_with_qs, body_params)
      else
        url_with_qs = add_qs_to_url(url, repackage(opts))
        http_adapter.get(url_with_qs)
      end
    end

    def url_params_and_body(opts)
      keys_for_body = [:keys]
      [opts.except(*keys_for_body), opts.slice(*keys_for_body)]
    end

    def repackage(opts)
      opts.each_with_object({}) do |(key, value), result|
        result[key] = jsonify_key?(key) ? jsonify_param(value) : value
      end
    end

    def jsonify_param(value)
      value.to_json
    end

    def jsonify_key?(key)
      [:key, :startkey, :endkey].include?(key.to_sym)
    end

    def add_qs_to_url(url, params)
      url + "?" + params.to_query
    end

    def http_adapter
      @http_adapter ||= HttpAdapter.new
    end
  end
end
