require 'ruby-libappindicator'

module LastPassIndicator
  class Menu
    def initialize(config)
      @config = config
      # FIXME: directory and license of icon file
      # https://commons.wikimedia.org/wiki/File:30x-Unlocked.png
      @indicator = AppIndicator::AppIndicator.new('lastpass_indicator',
                                                  'lastpass_indicator',
                                                  AppIndicator::Category::APPLICATION_STATUS,
                                                  THEME_PATH)
      @indicator.status = AppIndicator::Status::ACTIVE
      rebuild_menu
    end

    def rebuild_menu
      @indicator.menu = Gtk::Menu.new.tap do |menu|
        @config.accounts.sort_by { |account| account[:name] }.each do |account|
          menu.append menu_item(account_name(account)) { @account_handler.call(account) }
        end
        menu.append menu_item('Other...') { @other_handler.call }

        menu.append Gtk::SeparatorMenuItem.new
        menu.append menu_item('Configure') { @configure_handler.call }
        menu.append menu_item('Quit') { Gtk.main_quit }

        menu.show_all
      end
    end

    [:account, :other, :configure].each do |handler|
      define_method(:"on_#{handler}") { |&block| instance_variable_set :"@#{handler}_handler", block }
    end

    private

    THEME_PATH = File.expand_path(File.join __FILE__, '..', '..', '..', 'icons')

    def menu_item(label, &block)
      Gtk::MenuItem.new(label).tap do |item|
        item.signal_connect('activate', &block)
      end
    end

    def account_name(account)
      return account[:name] if account[:username].nil?
      "#{account[:name]} (#{account[:username]})"
    end
  end
end
