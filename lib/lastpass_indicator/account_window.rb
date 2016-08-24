
module LastPassIndicator
  class AccountWindow
    def initialize(vault)
      @vault = vault
      @dialog = Gtk::Dialog.new('Accounts', nil, nil,
                                [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                                [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])
      @dialog.set_default_size(400, 600)

      store = Gtk::ListStore.new(LastPass::Account, String)
      @vault.accounts.sort_by(&:name).each do |account|
        store.append.tap do |iter|
          iter[0] = account
          iter[1] = account_name(account)
        end
      end

      @treeview = Gtk::TreeView.new(store)
      @treeview.insert_column(-1, 'Account', Gtk::CellRendererText.new) do |_col, cell, _model, row|
        cell.text = account_name(row[0])
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

    def on_select(&block)
      @select_handler = block
    end

    private

    ACCOUNT_COL = 0
    TEXT_COL = 1

    def done(response)
      if response == Gtk::Dialog::RESPONSE_ACCEPT
        selected_row = @treeview.selection.selected
        @select_handler.call(selected_row[0]) unless selected_row.nil?
      end
      @dialog.destroy
    end

    # FIXME commonize with LoginWindow.account_name
    def account_name(account)
      return account.name if account.username.nil? || account.username.empty?
      "#{account.name} (#{account.username})"
    end
  end
end
