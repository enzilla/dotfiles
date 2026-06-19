return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      color_overrides = {
        mocha = {
          rosewater = "#DCD7BA",
          flamingo = "#C8C093",
          pink = "#A292A3",
          mauve = "#957FB8",
          red = "#C34043",
          maroon = "#E46876",
          peach = "#DCA561",
          yellow = "#C0A36E",
          green = "#76946A",
          teal = "#7AA89F",
          sky = "#7FB4CA",
          sapphire = "#7E9CD8",
          blue = "#7E9CD8",
          lavender = "#957FB8",
          text = "#DCD7BA",
          subtext1 = "#C8C093",
          subtext0 = "#A6A69C",
          overlay2 = "#727169",
          overlay1 = "#54546D",
          overlay0 = "#49495A",
          surface2 = "#363646",
          surface1 = "#2A2A37",
          surface0 = "#223249",
          base = "#1F1F28",
          mantle = "#16161D",
          crust = "#0D0C0C",
        },
      },
    },
  },
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
