module Slipcover
  class Config
    class << self
      attr_accessor :view_dir, :yaml_path
      attr_writer :env, :server
    end

    def self.env
      @env ||= ENV['RACK_ENV'] || 'development'
    end

    def self.server
      @server ||= Server.new(yaml_path, env)
    end

    def self.rails!
      self.env = Rails.env
      self.yaml_path = Rails.root.join('config/slipcover.yml') unless yaml_path
      self.view_dir = Rails.root.join('app', 'slipcover_views') unless view_dir
    end
  end
end
