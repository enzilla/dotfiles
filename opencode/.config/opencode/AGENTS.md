# Global opencode Workflow

Apply these defaults in every repository unless a project-level instruction overrides them.

- Inspect the repository before proposing or editing code.
- Prefer the smallest correct change over broad rewrites.
- Keep secrets, tokens, credentials, private keys, and machine-local state out of Git.
- Use Stow-compatible paths for dotfiles: each top-level package mirrors the final path under `$HOME`.
- Never run destructive Git or filesystem commands unless the user explicitly asks for them.
- When editing opencode config, validate field names against `https://opencode.ai/config.json` before writing.
- After changing opencode config, agents, commands, skills, plugins, or MCPs, remind the user to restart opencode.
- Treat MCPs as optional integrations. Do not require an MCP to complete work when regular repository tools are enough.
