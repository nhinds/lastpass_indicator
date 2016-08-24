require 'xdg'
require 'yaml'

module LastPassIndicator
  class ConfigDir
    include XDG::BaseDir::Mixin

    def subdirectory
      'lastpass_indicator'
    end
  end

  class Config
    def initialize
      @save_handlers = []
      @dir = ConfigDir.new
      config_file = @dir.config.find('account.yaml')
      if config_file
        @config = YAML.load_file config_file
      else
        @config = {}
      end
    end

    def username
      @config[:username]
    end

    def username=(username)
      @config[:username] = username
      save
    end

    def accounts
      @config.fetch :accounts, []
    end

    def accounts=(accounts)
      @config[:accounts] = accounts
      save
    end

    def on_save(&block)
      @save_handlers << block
    end

    private

    def save
      config_file = @dir.config.home.to_path + 'account.yaml'
      File.open(config_file, 'w') do |file|
        file.write(@config.to_yaml)
      end
      @save_handlers.each { |handler| handler.call }
    end
  end
end
