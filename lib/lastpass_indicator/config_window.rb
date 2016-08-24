
module LastPassIndicator
  class ConfigWindow
    def initialize(config, vault)
      @config = config
      @vault = vault
      @dialog = Gtk::Dialog.new('LastPass Indicator Configuration', nil, nil,
                                [Gtk::Stock::CLOSE, Gtk::Dialog::RESPONSE_CANCEL])
      @dialog.set_default_size(600, 600)

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
