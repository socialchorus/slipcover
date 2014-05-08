module Slipcover
  class Database
    attr_reader :name, :server

    def initialize(name, server=nil)
      @name = name
      @server = server || Slipcover::Config.server
    end

    def url
      "#{server.url}/#{name}_#{Slipcover::Config.env}"
    end

    # shared???

    def create
      RestClient.put(url, {}.to_json, headers)
    rescue RestClient::PreconditionFailed
      # handled by the ensure, move along
    ensure
      return info
    end

    def delete
      RestClient.delete(url, headers)
      true
    rescue
      false
    end

    def info
      parse( RestClient.get(url, headers) )
    end

    def headers
      {:content_type => :json, :accept => :json}
    end

    def parse(response)
      JSON.parse(response).symbolize_keys
    end
  end
end
