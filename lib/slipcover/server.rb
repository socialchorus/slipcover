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
      info = config['username'] || ""
      info << ":#{config['password']}" if config['password']
      info << "@" unless info.empty?
      info
    end

    def host
      config['host']
    end

    def port
      config['port'] ? ":#{config['port']}" : ''
    end
  end
end
