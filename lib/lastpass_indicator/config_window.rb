
module LastPassIndicator
  class ConfigWindow
    def initialize(config, vault)
      @config = config
      @vault = vault
      @dialog = Gtk::Dialog.new('LastPass Indicator Configuration', nil, nil,
                                [Gtk::Stock::CLOSE, Gtk::Dialog::RESPONSE_CANCEL])
      @dialog.set_default_size(600, 600)
      @dialog.vbox.spacing = 5

      store = Gtk::ListStore.new(LastPass::Account, String)
      @vault.accounts.sort_by(&:name).each do |account|
        store.append.tap do |iter|
          iter[0] = account
          iter[1] = Account.account_name(account)
        end
      end

      @treeview = Gtk::TreeView.new(store)
      toggle_renderer = Gtk::CellRendererToggle.new
      toggle_renderer.signal_connect('toggled') { |renderer, path| toggled(renderer, path) }
      @treeview.insert_column(-1, 'Shown', toggle_renderer) do |_col, cell, _model, row|
        cell.active = @config.accounts.any? { |account| account.id == row[0].id }
      end
      @treeview.insert_column(-1, 'Account', Gtk::CellRendererText.new) do |_col, cell, _model, row|
        cell.text = row[1]
      end
      @treeview.headers_visible = false
      @treeview.signal_connect('row-activated') { done(Gtk::Dialog::RESPONSE_ACCEPT) }
      @treeview.search_column = 1

      scrolled_win = Gtk::ScrolledWindow.new
      scrolled_win.add(@treeview)
      scrolled_win.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
      @dialog.vbox.pack_start(scrolled_win)

      focus_delay_row = Gtk::HBox.new
      focus_delay_row.tooltip_text = 'The time to pause between selecting the account and typing the password, to allow the window to regain focus'

      focus_delay_label = Gtk::Label.new('Focus Delay (seconds)')
      focus_delay_label.xalign = 1
      focus_delay_row.pack_start(focus_delay_label)

      @focus_delay = Gtk::SpinButton.new(0.1, 1.5, 0.1)
      @focus_delay.value = @config.focus_delay
      @focus_delay.signal_connect('value-changed') { @config.focus_delay = @focus_delay.value }
      focus_delay_row.pack_start(@focus_delay, false, false, 5)
      @dialog.vbox.pack_start(focus_delay_row, false)

      @dialog.signal_connect('response') { |_, response| done(response) }
      @dialog.default_response = Gtk::Dialog::RESPONSE_ACCEPT

      @dialog.show_all
    end

    private

    def done(response)
      @dialog.destroy
    end

    def toggled(renderer, path)
      row = @treeview.model.get_iter path
      account = Account.from_vault(row[0])
      if renderer.active?
        @config.remove_account account
      else
        @config.add_account account
      end
    end
  end
end
