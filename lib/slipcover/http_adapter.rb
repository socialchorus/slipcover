module Slipcover
  class HttpAdapter
    def head(url, data={})
      try {
        parse( RestClient.head(url + query_string(data), headers) )
      }
    end

    def get(url, data={})
      try {
        parse( RestClient.get(url + query_string(data), headers) )
      }
    end

    def post(url, data={})
      try {
        parse( RestClient.post(url, data.to_json, headers) )
      }
    end

    def put(url, data={})
      try {
        parse( RestClient.put(url, data.to_json, headers) )
      }
    end

    def delete(url, data={})
      try {
        parse( RestClient.delete(url + query_string(data), headers) )
      }
    end

    def query_string(data)
      return "" if data.empty?

      query = data.map do |key, value|
        "#{key}=#{value}"
      end.join("&")

      "?#{query}"
    end

    def parse(response)
      parsed = JSON.parse(response)
      parsed.is_a?(Hash) ? parsed.symbolize_keys : parsed
    end

    def try
      yield
    rescue Exception => e
      reraise(e)
    end

    def reraise(e)
      # As we keep doing more stuff with couchdb we might want to update this list
      response = JSON.parse(e.response) rescue Hash.new
      case response["reason"]
      when "no_db_file" then raise DBNotFound, e.response
      when "Database does not exist." then raise DBNotFound, e.response
      when "missing_named_view" then raise NamedViewNotFound, e.response
      when "missing" then raise DocumentNotFound, e.response
      else
        raise error_class(e).new(response.empty? ? e.message : e.response)
      end
    end

    def error_class(e)
      {
        JSON::ParserError => ParseError,
        RestClient::ResourceNotFound => NotFound,
        RestClient::PreconditionFailed => ConflictError,
        RestClient::Conflict => ConflictError

      }[e.class] || e.class
    end

    class ConflictError < RuntimeError
    end

    class ParseError < RuntimeError
    end

    class NotFound < RuntimeError
    end

    class DBNotFound < RuntimeError
    end

    class NamedViewNotFound < RuntimeError
    end

    class DocumentNotFound < RuntimeError
    end

    def headers
      {:content_type => :json, :accept => :json}
    end
  end
end
