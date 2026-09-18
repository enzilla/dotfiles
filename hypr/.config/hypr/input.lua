-- Preferências pessoais de input. Portável entre máquinas.
--
-- O layout do teclado NÃO fica aqui de propósito: o default do Omarchy lê
-- XKBLAYOUT de /etc/vconsole.conf, que é config de sistema, por máquina.
-- Para trocar numa máquina:  sudo localectl set-x11-keymap <layout>

hl.config({
  input = {
    -- Caps Lock continua sendo Caps Lock. O default do Omarchy transforma o
    -- Caps em tecla de composição (compose:caps,shift:both_capslock_cancel).
    kb_options = "",

    repeat_rate = 40,
    repeat_delay = 600,

    numlock_by_default = true,

    sensitivity = -0.7,

    touchpad = {
      scroll_factor = 0.4,
    },
  },
})

-- Rolagem mais rápida no terminal.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
