namespace :slipcover do
  namespace :db do
    desc "Pull all CouchDB databases from the target environment into the local CouchDB"
    task :pull, [:stage_name, :query] => (:environment if defined?(Rails)) do |t, args|
      require 'slipcover/dev_tools'
      logger = Logger.new(STDOUT)
      logger.level = ENV["DEBUG"] ? Logger::DEBUG : Logger::INFO
      stage = args[:stage_name] || "staging"
      query = args[:query] || ""
      Slipcover::DevTools::Replicator.new(
        source_environment: stage,
        target_environment: 'development',
        database_name: query,
        logger: logger
      ).perform
    end
  end
end
