module Slipcover
  class HttpAdapter
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
      JSON.parse(response).symbolize_keys
    end

    def try
      yield
    rescue Exception => e
      reraise(e)
    end

    def reraise(e)
      raise error_class(e).new(e.message)
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

    def headers
      {:content_type => :json, :accept => :json}
    end
  end
end
