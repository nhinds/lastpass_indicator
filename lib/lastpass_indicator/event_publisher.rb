
module LastPassIndicator
  # Support for publishing events
  module EventPublisher
    # Allow one or more events to be published
    # For each given symbol, creates a method `on_<event>` which other classes can call to listen for the given event, and creates a private
    # method `publish_<event>` to notify listeners. Any arguments to `publish_<event>` are passed to each listener for that event.
    def events(*events)
      events.each do |event|
        define_method(:"#{event}_handlers") do
          handlers = instance_variable_get(:"@#{event}_handlers")
          if handlers.nil?
            handlers = []
            instance_variable_set(:"@#{event}_handlers", handlers)
          end
          handlers
        end
        private :"#{event}_handlers"

        define_method(:"on_#{event}") do |&block|
          send(:"#{event}_handlers") << block
        end

        define_method(:"publish_#{event}") do |*args|
          send(:"#{event}_handlers").each do |handler|
            handler.call *args
          end
        end
        private :"publish_#{event}"
      end
    end
    module_function :events
    alias_method :event, :events
  end
end
