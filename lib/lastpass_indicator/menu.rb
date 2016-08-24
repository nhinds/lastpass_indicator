require 'ruby-libappindicator'
require 'lastpass_indicator/event_publisher'

module LastPassIndicator
  class Menu
    extend EventPublisher
    events :account, :other, :configure

    def initialize(config)
      @config = config
      # FIXME: directory and license of icon file
      # https://commons.wikimedia.org/wiki/File:30x-Unlocked.png
      @indicator = AppIndicator::AppIndicator.new('lastpass_indicator',
                                                  'lastpass_indicator',
                                                  AppIndicator::Category::APPLICATION_STATUS,
                                                  THEME_PATH)
      @indicator.set_status AppIndicator::Status::ACTIVE
      @config.on_save { rebuild_menu }
      rebuild_menu
    end

    def rebuild_menu
      @indicator.set_menu(Gtk::Menu.new.tap do |menu|
        @config.accounts.sort_by(&:name).each do |account|
          menu.append menu_item(account.to_s) { publish_account(account) }
        end
        menu.append menu_item('Other...') { publish_other }

        menu.append Gtk::SeparatorMenuItem.new
        menu.append menu_item('Configure') { publish_configure }
        menu.append menu_item('Quit') { Gtk.main_quit }

        menu.show_all
      end)
    end

    private

    THEME_PATH = File.expand_path(File.join __FILE__, '..', '..', '..', 'icons')

    def menu_item(label, &block)
      Gtk::MenuItem.new(label).tap do |item|
        item.signal_connect('activate', &block)
      end
    end
  end
end
