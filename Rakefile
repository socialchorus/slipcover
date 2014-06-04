require "bundler/gem_tasks"

task :console do
  require 'irb'
  require 'irb/completion'
  require 'slipcover'
  Slipcover::Config.yaml_path = File.expand_path("../spec/support/slipcover.yml", __FILE__)
  Slipcover::Config.view_dir = File.expand_path("../spec/support/slipcover_views", __FILE__)
  ARGV.clear
  IRB.start
end

