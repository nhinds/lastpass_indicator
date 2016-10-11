require 'xdo/keyboard'

module LastPassIndicator
  class PasswordOutput
    def self.write_password(account, menu)
      Thread.start do
        menu.mark_active_while do
          # Give other windows a chance to focus
          sleep 1
          # xdo gem has a bug where single quotes are passed directly to the shell. Make that a little safer.
          safe_password = account.password.gsub "'", "'\\''"
          XDo::Keyboard.type safe_password
        end
      end
    end
  end
end
