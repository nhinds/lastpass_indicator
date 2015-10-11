require 'gtk2'

module LastPassIndicator
  class LoginWindow
    # TODO: rewrite with a builder / glade file?
    def initialize(config, reprompt: false)
      @config = config
      @reprompt = reprompt
      @dialog = Gtk::Dialog.new(@reprompt ? 'Password Reprompt' : 'Login')
      @dialog.resizable = false

      username_label = Gtk::Label.new 'Username'
      @username = Gtk::Entry.new
      @username.text = @config.username if @config.username
      @username.signal_connect('changed') { update_sensitivity }
      [username_label, @username].each { |widget| widget.no_show_all = reprompt }

      password_label = Gtk::Label.new 'Password'
      @password = Gtk::Entry.new
      @password.visibility = false
      @password.activates_default = true
      @password.signal_connect('changed') { update_sensitivity }

      table = Gtk::Table.new(2, 2)
      table.attach(username_label, 0, 1, 0, 1, 0)
      table.attach(@username, 1, 2, 0, 1)
      table.attach(password_label, 0, 1, 1, 2, 0)
      table.attach(@password, 1, 2, 1, 2)
      table.row_spacings = 5
      table.column_spacings = 5
      table.border_width = 5
      @dialog.vbox.add table

      @spinner = Gtk::Spinner.new
      @spinner.no_show_all = true
      # Hide the spinner in a box, otherwise it ends up huge with ridiculous padding
      spinner_box = Gtk::HBox.new
      spinner_box.pack_end(@spinner, false)
      @dialog.action_area.pack_start(spinner_box)
      @dialog.add_button('Login', Gtk::Dialog::RESPONSE_ACCEPT)

      @dialog.signal_connect('response') { |_, response| done(response) }
      @dialog.default_response = Gtk::Dialog::RESPONSE_ACCEPT

      update_sensitivity
      @password.grab_focus if @config.username
      @dialog.show_all
    end

    def on_login(&block)
      @login_handler = block
    end

    def finished(success)
      if success
        @dialog.destroy
      else
        @spinner.stop
        @spinner.hide
        update_sensitivity(sensitive: true, fields: true)
      end
    end

    private

    def done(response)
      if response == Gtk::Dialog::RESPONSE_ACCEPT
        @config.username = @username.text unless @reprompt
        update_sensitivity(sensitive: false, fields: true)
        @spinner.start
        @spinner.show
        @login_handler.call(@config.username, @password.text)
      else
        @dialog.destroy
      end
    end

    def update_sensitivity(sensitive: !@username.text.empty? && !@password.text.empty?, fields: false)
      @dialog.set_response_sensitive(Gtk::Dialog::RESPONSE_ACCEPT, sensitive)
      [@username, @password].each { |field| field.sensitive = sensitive } if fields
    end
  end
end
