module Slipcover
  class Config
    class << self
      attr_accessor :server
    end

    def self.rails!
      self.server = Server.new(Rails.root.join('config/slipcover.yml'), Rails.env)
    end
  end
end
