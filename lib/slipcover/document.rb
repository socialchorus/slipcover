module Slipcover
  class Document
    attr_accessor :attributes, :id, :rev
    attr_reader :database_name

    def initialize(database_name, attributes={})
      @database_name = database_name
      self.attributes = attributes.symbolize_keys
      set_intrinsic_values
    end

    delegate :[], :[]=, to: :attributes

    def http_adapter
      @http_adapter ||= HttpAdapter.new
    end

    delegate :get, :post, :put,
      to: :http_adapter

    def save
      http_method = id ? :put : :post
      doc_url = id ? url : database.url
      response = send(http_method, doc_url, attributes_for_save)
      set_intrinsic_values(response)
    end

    def fetch
      self.attributes = get(url)
      set_intrinsic_values
    rescue Slipcover::HttpAdapter::DocumentNotFound
    end

    def delete
      http_adapter.delete("#{url}?rev=#{rev}")
      set_intrinsic_values({})
      nullify_intrinsic_attributes
      true
    rescue Exception => e
      false
    end

    def url
      raise ArgumentError.new('no document id') unless id
      "#{database.url}/#{CGI::escape(id)}"
    end

    def database
      @database ||= Slipcover::Database.new(database_name)
    end

    private

    def attributes_for_save
      attrs = attributes.clone
      attrs[:_rev] = rev if rev
      attrs[:_id]  = id if id
      attrs
    end

    def set_intrinsic_values(attrs=nil)
      attrs ||= attributes
      self.id =   attrs[:id] || attrs[:_id]
      self.rev =  attrs[:rev] || attrs[:_rev]
    end

    def nullify_intrinsic_attributes
      attributes[:_id] = nil
      attributes[:id] = nil
      attributes[:_rev] = nil
      attributes[:rev] = nil
    end
  end
end
