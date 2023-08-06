# frozen_string_literal: true

class Scarpe
  # Scarpe::WASMApp must only be used from the main thread, due to GTK+ limitations.
  class WASMApp < WASMWidget
    attr_reader :control_interface

    attr_writer :shoes_linkable_id

    def initialize(properties)
      super

      # It's possible to provide a Ruby script by setting
      # SCARPE_TEST_CONTROL to its file path. This can
      # allow pre-setting test options or otherwise
      # performing additional actions not written into
      # the Shoes app itself.
      #
      # The control interface is what lets these files see
      # events, specify overrides and so on.
      @control_interface = ControlInterface.new
      if ENV["SCARPE_TEST_CONTROL"]
        require "scarpe/unit_test_helpers"
        @control_interface.instance_eval File.read(ENV["SCARPE_TEST_CONTROL"])
      end

      # TODO: rename @view
      @view = Scarpe::WebWrangler.new title: @title,
        width: @width,
        height: @height,
        resizable: @resizable

      @callbacks = {}

      # The control interface has to exist to get callbacks like "override Scarpe app opts".
      # But the Scarpe App needs those options to be created. So we can't pass these to
      # ControlInterface.new.
      @control_interface.set_system_components app: self, doc_root: nil, wrangler: @view

      bind_shoes_event(event_name: "init") { init }
      bind_shoes_event(event_name: "run") { run }
      bind_shoes_event(event_name: "destroy") { destroy }
    end

    attr_writer :document_root

    def init
      scarpe_app = self

      @view.init_code("scarpeInit") do
        request_redraw!
      end

      @view.bind("scarpeHandler") do |*args|
        handle_callback(*args)
      end

      @view.bind("scarpeExit") do
        scarpe_app.destroy
      end
    end

    def run
      @control_interface.dispatch_event(:init)

      # This takes control of the main thread and never returns. And it *must* be run from
      # the main thread. And it stops any Ruby background threads.
      # That's totally cool and normal, right?
      @view.run
    end

    def destroy
      if @document_root || @view
        @control_interface.dispatch_event :shutdown
      end
      @document_root = nil
      if @view
        @view.destroy
        @view = nil
      end
    end

    # All JS callbacks to Scarpe widgets are dispatched
    # via this handler
    def handle_callback(name, *args)
      @callbacks[name].call(*args)
    end

    # Bind a Scarpe callback name; see handle_callback above.
    # See Scarpe::Widget for how the naming is set up
    def bind(name, &block)
      @callbacks[name] = block
    end

    # Request a full redraw if WASM is running. Otherwise
    # this is a no-op.
    #
    # @return [void]
    def request_redraw!
      wrangler = WASMDisplayService.instance.wrangler
      if wrangler.is_running
        wrangler.replace(@document_root.to_html)
      end
      nil
    end
  end
end
