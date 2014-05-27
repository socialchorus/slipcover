require 'yaml'
module Slipcover
  class Server < Struct.new(:path, :key)
    def server_configs
      YAML.load(File.read(path))
    end

    def config
      @config ||= server_configs[key]
    end

    def url
      "#{user_info}#{host}#{port}"
    end

    def user_info
      info = "" + username
      info << ":#{password}" unless info.empty?
      info << "@" unless info.empty?
      info
    end

    def host
      config['host']
    end

    def port
      config['port'] ? ":#{config['port']}" : ''
    end

    # We're interpolating this because Ruby freezes double hash reference strings
    def username
      config['couch_username_key'] ? "#{ENV[config['couch_username_key']]}" : ""
    end

    def password
      config['couch_password_key'] ? "#{ENV[config['couch_password_key']]}" : ""
    end
  end
end
