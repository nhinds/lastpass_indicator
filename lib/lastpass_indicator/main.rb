require 'lastpass'

module LastPassIndicator
  class Main
    def initialize
      @config = Config.new
      @menu = Menu.new(@config)
      @menu.on_account do |selected_account|
        puts "Asked for #{selected_account}"
        retrieve_vault do |vault|
          accounts = vault.accounts.select { |account| account.id == selected_account[:id] }
          if accounts.any?
            account = accounts.first
            PasswordOutput.write_password account
          else
            error_dialog "Unknown account '#{selected_account[:name]}'\nID #{selected_account[:id]} not found"
          end
        end
      end
      @menu.on_other do
        puts 'Dunno, pick one:'
        retrieve_vault do |vault|
          vault.accounts.each do |account|
            puts "#{account.id} - #{account.name} (#{account.username})"
          end
        end
      end
    end

    def run
      Gtk.main
    end

    private

    # Obtain the decrypted LastPass vault
    #
    # Prompts for username (if required) and password - asynchronously with a GTK dialog
    # Retrieves the encrypted blob from LastPass (if required) - asynchronously on a non-GTK thread
    # Yields the decrypted vault to the given block - back in the GTK main loop
    def retrieve_vault(&block)
      # TODO: cache blob so we don't have to talk to LastPass every time
      login_window = LoginWindow.new(@config)
      login_window.on_login do |username, password|
        Thread.start do
          begin
            vault = LastPass::Vault.open_remote username, password
            idle do
              login_window.finished(true)
              block.call(vault)
            end
          rescue LastPass::Error => e
            # TODO: handle multifactor prompts (maybe handle duo magic)
            error_dialog "Error logging into LastPass: #{e.message}"
            idle { login_window.finished(false) }
          end
        end
      end
    end

    def error_dialog(msg)
      idle do
        dialog = Gtk::MessageDialog.new(nil, nil, Gtk::MessageDialog::ERROR, Gtk::MessageDialog::BUTTONS_OK, msg)
        dialog.signal_connect('response') { dialog.destroy }
        dialog.show_all
      end
    end

    def idle(&block)
      Gtk.idle_add do
        block.call
        # Please don't call us again, GTK
        false
      end
    end
  end
end
