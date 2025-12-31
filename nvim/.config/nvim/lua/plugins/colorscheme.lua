return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = true,
  --   opts = { style = "night" },
  -- },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  -- {
  --   "akinsho/bufferline.nvim",
  --   optional = true,
  --   opts = function(_, opts)
  --     if (vim.g.colors_name or ""):find("catppuccin") then
  --       opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
  --     end
  --   end,
  -- },
}
