require 'json'
require 'rest-client'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module/delegation'

require "slipcover/version"
require "slipcover/http_adapter"
require "slipcover/server"
require "slipcover/config"
require "slipcover/database"
require "slipcover/document"
require "slipcover/design_document"

require 'slipcover/railtie' if defined?(Rails)
