require 'xdo/keyboard'

module LastPassIndicator
  class PasswordOutput
    def self.write_password(account)
      Thread.start do
        # Give other windows a chance to focus
        sleep 0.5
        # xdo gem has a bug where single quotes are passed directly to the shell. Make that a little safer.
        safe_password = account.password.gsub "'", "'\\''"
        XDo::Keyboard.type safe_password
      end
    end
  end
end
