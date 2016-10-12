require 'xdg'
require 'yaml'
require 'lastpass_indicator/event_publisher'

module LastPassIndicator
  class ConfigDir
    include XDG::BaseDir::Mixin

    def subdirectory
      'lastpass_indicator'
    end
  end

  class Config
    extend EventPublisher
    event :save

    def initialize
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
      @config.fetch(:accounts, []).map { |account| Account.from_hash account }
    end

    def add_account(account)
      @config[:accounts] ||= []
      @config[:accounts] << account.to_h
      save
    end

    def remove_account(account)
      @config[:accounts].delete_if { |config_account| config_account[:id] == account.id }
      save
    end

    def focus_delay
      @config[:focus_delay] || 0.5
    end

    def focus_delay=(focus_delay)
      @config[:focus_delay] = focus_delay
      save
    end

    private

    def save
      config_file = @dir.config.home.to_path + 'account.yaml'
      File.open(config_file, 'w') do |file|
        file.write(@config.to_yaml)
      end
      publish_save
    end
  end
end
