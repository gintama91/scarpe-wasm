# frozen_string_literal: true

class Scarpe
  class WASMStack < Scarpe::WASMSlot
    def get_style
      style
    end

    protected

    def style
      styles = super

      styles[:display] = "flex"
      styles["flex-direction"] = "column"
      styles["align-content"] = "flex-start"
      styles["justify-content"] = "flex-start"
      styles["align-items"] = "flex-start"
      styles["overflow"] = "auto" if @scroll

      styles
    end
  end
end
