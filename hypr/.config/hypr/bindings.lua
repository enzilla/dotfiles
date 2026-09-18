-- Keep only your personal keybinding overrides here.
--
-- Na migração 3.8.5 -> 4.0.4 os 23 atalhos do bindings.conf antigo foram
-- conferidos um a um: o Omarchy 4 moveu todos os apps para SUPER+SHIFT+<letra>,
-- liberando SUPER+<letra> para gerenciamento de janela. Optamos por adotar os
-- defaults novos, então nada precisou ser reposto — exceto o abaixo, que o
-- Omarchy 4 não tem.

o.bind("SUPER + CTRL + G", "Google Messages",
  'omarchy-launch-or-focus-webapp "Google Messages" "https://messages.google.com/web/conversations"')
