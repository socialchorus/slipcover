require 'net/http'
require 'fileutils'
require 'logger'
require 'json'

module Slipcover
  module DevTools

    class Replicator
      attr_reader :source_environment, :source_server
      attr_reader :target_environment, :target_server
      attr_reader :database_name, :logger, :http

      def initialize(opts)
        @source_environment = opts[:source_environment] || "staging"
        @target_environment = opts[:target_environment] || "development"
        @database_name = opts[:database_name]
        @logger = opts[:logger] || Logger.new("/dev/null")

        @source_server = Slipcover::Server.new(Slipcover::Config.yaml_path, source_environment)
        @target_server = Slipcover::Server.new(Slipcover::Config.yaml_path, target_environment)

        @http = HttpAdapter.new
      end

      def perform
        logger.info "Fetching list of #{source_environment} databases#{" containing string \"" + database_name + "\"" if database_name}..."
        logger.info "Replicating these dbs: #{dbs_to_replicate.join(",")}"

        dbs_to_replicate.each_with_index.map do |db, i|
          Thread.new(db, i, &method(:replicate))
        end.map(&:join)
      end


      private

      def dbs_to_replicate
        @dbs_to_replicate ||= begin
          require 'slipcover/http_adapter'
          dbs = http.get(source_server.url + "/_all_dbs")
          dbs.select { |db| db_matches?(db) }
        end
      end

      def db_matches?(db)
        matches = db.end_with?(source_environment)
        matches &&= db.include?(database_name) if database_name
        matches
      end

      def replicate(source_db_name, th_id)
        target_db_name = infer_target_db_name(source_db_name)
        source_url = db_url(source_server, source_db_name)
        target_url = db_url(target_server, target_db_name)

        logger.info "#{th_id}: Replicating #{source_url} into #{target_url}"

        response = http.post(target_server.url + "/_replicate", { source: source_url, target: target_url, create_target: true })

        logger.debug("#{th_id}: " + response.to_json)

        raise "#{th_id}: Replication of #{source_url} into #{target_url} failed" unless response[:ok]

        logger.info "#{th_id}: Done replicating #{source_url} into #{target_url}"
      end

      def infer_target_db_name(source_db_name)
        source_db_name.sub(/#{source_environment}$/, target_environment)
      end

      def db_url(server, db_name)
        "http://" + server.url + "/" + db_name
      end
    end

  end
end
