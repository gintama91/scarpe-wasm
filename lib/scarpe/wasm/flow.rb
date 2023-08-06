# frozen_string_literal: true

class Scarpe
  class WASMFlow < Scarpe::WASMSlot
    def initialize(properties)
      super
    end

    protected

    def style
      styles = super

      styles[:display] = "flex"
      styles["flex-direction"] = "row"
      styles["flex-wrap"] = "wrap"
      styles["align-content"] = "flex-start"
      styles["justify-content"] = "flex-start"
      styles["align-items"] = "flex-start"

      styles
    end
  end
end
