# Neovim Dotfiles

Welcome to my Neovim configuration repository!  
This setup is designed for a modern, efficient, and highly customizable Neovim experience leveraging Lua and a robust plugin ecosystem managed by Lazy.nvim.

---

## Overview

My Neovim dotfiles utilize [Lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager, focusing on speed, modularity, and extensibility. The configuration aims to provide:

- Intuitive code editing with smart completions and snippets.
- Advanced LSP integration for multiple languages.
- Git integration and code diagnostics.
- Comfortable UI and navigation enhancements.
- Tools for testing, debugging, and refactoring.
- Themes and statusline customization.
- Productivity utilities like todo comments, code formatting, and session persistence.

---

## Key Plugins & Features

### Core Framework & Plugin Management

- **Lazy.nvim**: The backbone plugin manager, enabling lazy loading and fast startup.
- **LazyVim**: Provides a strong base configuration and sensible defaults.

### Code Completion & Snippets

- **nvim-cmp** + sources:
  - `cmp-buffer` — buffer completions
  - `cmp-path` — filesystem paths
  - `cmp-git` — git completions
  - `cmp-nvim-lsp` — LSP completions
  - `cmp_luasnip` — snippet completions
- **LuaSnip**: Snippet engine with community snippets via `friendly-snippets`.
- **copilot.lua** and **copilot-cmp**: GitHub Copilot integration for AI-powered completions.

### Language Server Protocol (LSP)

- **mason.nvim** + **mason-lspconfig.nvim**: Easy management and installation of LSP servers.
- **nvim-lspconfig**: Configurations for language servers.
- **clangd_extensions.nvim**: Extra tooling for C/C++ LSP.
- **cmake-tools.nvim**: CMake integration.
- **nvim-jdtls**: Java LSP support.

### Debugging & Testing

- **nvim-dap** + related extensions (`dap-ui`, `dap-python`, `dap-virtual-text`): Debug Adapter Protocol support for debugging.
- **neotest** + **neotest-python**: Integrated testing framework.

### UI & Navigation

- **alpha-nvim**: Startup dashboard.
- **bufferline.nvim**: Enhanced buffer/tab line.
- **lualine.nvim**: Customizable status line.
- **catppuccin** and **tokyonight.nvim**: Beautiful themes.
- **noice.nvim**: Enhanced UI for messages, command line, and notifications.
- **which-key.nvim**: Displays available keybindings in popup.
- **trouble.nvim**: Diagnostics and quickfix list viewer.
- **flash.nvim**: Enhanced motion/navigation plugin.
- **vim-tmux-navigator**: Seamless navigation between Vim and tmux panes.

### Editing & Productivity Enhancements

- **mini.nvim suite**: Provides multiple small utilities for comments, pairs, surround, icons, etc.
- **dial.nvim**: Increment/decrement plugin.
- **inc-rename.nvim**: Incremental renaming for LSP.
- **todo-comments.nvim**: Highlights TODO and similar comments.
- **yanky.nvim**: Enhanced yank and paste with history.
- **refactoring.nvim**: Code refactoring tools.
- **conform.nvim** and **none-ls.nvim**: Code formatting and linting.
- **nvim-lint**: On-the-fly linting.

### Markdown & Web Development

- **markdown-preview.nvim**: Live markdown preview in browser.
- **live-server-nvim**: Live reload server for web development.
- **tailwindcss-colorizer-cmp.nvim**: Tailwind CSS color highlighter in completion.
- **nvim-ts-autotag**: Auto-closing and renaming HTML tags.
- **nvim-ts-context-commentstring**: Context-aware comment strings.

### Git & Version Control

- **gitsigns.nvim**: Git integration for signs, blame, and hunk actions.

### Miscellaneous

- **schema-store.nvim**: JSON schema store integration for better JSON validation.
- **outline.nvim**: Code outline sidebar.
- **persistence.nvim**: Session persistence.
- **lorem.nvim**: Generate lorem ipsum text quickly.
- **codesnap.nvim**: Take screenshots of code snippets.

---

## Credits

This configuration heavily relies on the incredible Neovim community and plugins by:

- [folke](https://github.com/folke)
- [hrsh7th](https://github.com/hrsh7th)
- [neovim](https://github.com/neovim/neovim)
- [catppuccin](https://github.com/catppuccin)
- And many other plugin authors listed in the plugin list.

---
