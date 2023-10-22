# frozen_string_literal: true

module Scarpe::WASM
  class Radio < Drawable
    attr_reader :text

    def initialize(properties)
      super

      bind("click") do
        send_self_event(event_name: "click", target: shoes_linkable_id)
      end
    end

    def properties_changed(changes)
      items = changes.delete("checked")
      html_element.toggle_input_button(items)

      super
    end

    def element
      props = shoes_styles

      # If a group isn't set, default to the linkable ID of the parent slot
      unless @group
        props["group"] = @parent ? @parent.shoes_linkable_id : "no_group"
      end
      render("radio", props)
    end
  end
end
