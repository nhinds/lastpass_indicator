require 'lastpass'
require 'active_support/core_ext/numeric/time'

module LastPassIndicator
  class Main
    def initialize
      @config = Config.new
      @menu = Menu.new(@config)
      @password_output = PasswordOutput.new(@menu, @config)
      @menu.on_account do |selected_account|
        puts "Asked for #{selected_account}"
        with_vault do |vault|
          accounts = vault.accounts.select { |account| account.id == selected_account.id }
          if accounts.any?
            account = accounts.first
            @password_output.write_password account
          else
            error_dialog "Unknown account '#{selected_account.name}'\nID #{selected_account.id} not found"
          end
        end
      end
      @menu.on_other do
        with_vault do |vault|
          account_window = AccountWindow.new(vault)
          account_window.on_select do |account|
            @password_output.write_password account
          end
        end
      end
      @menu.on_configure do
        with_vault do |vault|
          ConfigWindow.new(@config, vault)
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
    def with_vault(&block)
      # Short circuit all of this if the vault has been kept open
      return block.call(@vault) if @vault

      login_window = LoginWindow.new(@config, reprompt: !@blob.nil?)
      login_window.on_login do |username, password, remember|
        Thread.start do
          begin
            @blob ||= LastPass::Vault.fetch_blob username, password
            vault = LastPass::Vault.open @blob, username, password

            if remember
              @vault = vault
              Gtk.timeout_add(5.minutes.in_milliseconds) { @vault = nil }
            end

            idle do
              login_window.finished(true)
              block.call(vault)
            end
          rescue LastPass::Error, OpenSSL::OpenSSLError => e
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
