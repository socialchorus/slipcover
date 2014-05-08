require 'json'
require 'rest-client'
require 'active_support/core_ext/hash'

require "slipcover/version"
require "slipcover/server"
require "slipcover/config"
require "slipcover/database"
require "slipcover/document"

require 'slipcover/railtie' if defined?(Rails)
