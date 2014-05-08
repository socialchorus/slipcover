module Slipcover
  class Config
    class << self
      attr_accessor :server
      attr_writer :env
    end

    def self.env
      @env ||= ENV['RACK_ENV'] || 'development'
    end

    def self.rails!
      self.env = Rails.env
      self.server = Server.new(Rails.root.join('config/slipcover.yml'), env)
    end
  end
end
