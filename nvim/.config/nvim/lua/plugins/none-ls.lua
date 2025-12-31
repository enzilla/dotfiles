return {
  "nvimtools/none-ls.nvim",
  optional = true,
  opts = function(_, opts)
    local nls = require("null-ls")

    local formatting = nls.builtins.formatting
    local diagnostics = nls.builtins.diagnostics

    opts.sources = opts.sources or {}
    vim.list_extend(opts.sources, {
      formatting.prettier,
      formatting.duster,
      formatting.xmllint,
      diagnostics.djlint,
    })

    formatting.prettier.with({
      command = "prettier",
      extra_args = { "--plugin", "prettier-plugin-tailwindcss" },
    })
  end,
}
