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

    def http_adapter
      @http_adapter ||= HttpAdapter.new
    end

    delegate :get, :post, :put,
      to: :http_adapter

    def create
      put(url)
    rescue HttpAdapter::ConflictError
    end

    def delete
      http_adapter.delete(url)
      true
    rescue Exception => e
      false
    end

    def info
      get(url)
    end
  end
end
