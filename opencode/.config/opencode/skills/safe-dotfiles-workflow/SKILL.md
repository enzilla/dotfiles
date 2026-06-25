---
name: safe-dotfiles-workflow
description: Use when editing dotfiles, GNU Stow packages, opencode config, shell config, terminal config, tmux, Neovim, or cross-device developer environment setup.
---

# Safe Dotfiles Workflow

Use this skill for personal environment changes that must work across devices.

## Rules

- Keep each app in its own top-level Stow package.
- Mirror the target home path inside each package, for example `opencode/.config/opencode/opencode.jsonc`.
- Never store machine-local secrets, credentials, auth state, caches, or logs in the repository.
- Prefer environment-variable references for secrets, such as `{env:GITHUB_TOKEN}` in opencode MCP headers.
- Make optional integrations disabled by default when they require extra binaries, browser installs, tokens, or network access.
- Document activation and verification commands in the repository README.

## Change Flow

1. Inspect existing packages and README conventions.
2. Add the smallest Stow-compatible file layout.
3. Run a dry-run Stow command before suggesting activation.
4. Verify generated JSON or JSONC against the relevant schema when possible.
5. Remind the user to restart apps that load config only at startup.
