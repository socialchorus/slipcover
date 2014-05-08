module Slipcover
  class Railtie < Rails::Railtie
    initializer "slipcover.configure_rails_initialization" do
      Slipcover::Config.rails!      
    end
  end
end
