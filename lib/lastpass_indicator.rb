require 'lastpass_indicator/config'
require 'lastpass_indicator/login_window'
require 'lastpass_indicator/main'
require 'lastpass_indicator/menu'
require 'lastpass_indicator/password_output'
require 'lastpass_indicator/version'

module LastPassIndicator
  def self.run
    Main.new.run
  end
end
