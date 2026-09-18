-- Portado de looknfeel.conf na migração 3.8.5 -> 4.0.4.
-- Defaults do Omarchy 4: gaps_in 5, gaps_out 10, rounding 0.

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
  },
  decoration = {
    rounding = 8,

    -- Desfoque atrás de janelas transparentes (o kitty está em
    -- background_opacity 0). O default do Omarchy vem desligado.
    blur = {
      enabled = true,
      size = 8,
      passes = 3,
      noise = 0.02,
    },
  },
})
