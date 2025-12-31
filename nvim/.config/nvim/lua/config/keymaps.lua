-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

map("n", "<leader>bt", function()
  require("live-server-nvim").toggle()
end, { desc = "Toggle LiveServer" })

map("v", "<Tab>", ">gv", { desc = "Indent and reselect" })
map("v", "<S-Tab>", "<gv", { desc = "Outdent and reselect" })
-- Tmux Navigator
map("n", "<C-h>", "<cmd> TmuxNavigateLeft<CR>", { desc = "Tmux Navigate Left" })
map("n", "<C-l>", "<cmd> TmuxNavigateRight<CR>", { desc = "Tmux Navigate Right" })
map("n", "<C-k>", "<cmd> TmuxNavigateUp<CR>", { desc = "Tmux Navigate Up" })
map("n", "<C-j>", "<cmd> TmuxNavigateDown<CR>", { desc = "Tmux Navigate Down" })
map("n", "<C-\\>", "<cmd> TmuxNavigatePrevious<CR>", { desc = "Tmux Navigate Previous" })

-- Hop
map("n", "F", "<cmd> HopWord<CR>", { desc = "Hop to character after cursor" })
