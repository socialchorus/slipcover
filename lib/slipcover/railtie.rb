module Slipcover
  class Railtie < Rails::Railtie
    initializer "slipcover.configure_rails_initialization" do
      Slipcover::Config.rails!
    end

    rake_tasks do
      require File.dirname(__FILE__) + "/tasks.rb"
    end
  end
end
