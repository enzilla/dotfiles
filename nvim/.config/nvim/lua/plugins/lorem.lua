return {
  {
    "maarutan/lorem.nvim",
    config = function()
      require("lorem").setup({
        formatter_enabled = true,
      })
    end,
  },
}
