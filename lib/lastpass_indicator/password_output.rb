require 'xdo/keyboard'

module LastPassIndicator
  class PasswordOutput
    def initialize(menu, config)
      @menu = menu
      @config = config
    end

    def write_password(account)
      Thread.start do
        @menu.mark_active_while do
          # Give other windows a chance to focus
          sleep @config.focus_delay
          # xdo gem has a bug where single quotes are passed directly to the shell. Make that a little safer.
          safe_password = account.password.gsub "'", "'\\''"
          XDo::Keyboard.type safe_password
        end
      end
    end
  end
end
