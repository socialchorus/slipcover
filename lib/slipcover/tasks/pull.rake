namespace :slipcover do
  namespace :db do
    desc "Pull all CouchDB databases from the target environment into the local CouchDB"
    task :pull, [:stage_name] => (:environment if defined?(Rails)) do |t, args|
      require 'slipcover/dev_tools'
      logger = Logger.new(STDOUT)
      logger.level = ENV["DEBUG"] ? Logger::DEBUG : Logger::INFO
      stage = args[:stage_name] || "staging"
      Slipcover::DevTools::Replicator.new(stage, "development", logger).perform
    end
  end
end
