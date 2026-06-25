---
description: Check the global opencode Stow package and summarize whether it is safe to activate.
agent: workbench
---

Check the opencode configuration package in this dotfiles repository.

Tasks:
- Inspect `opencode/.config/opencode/opencode.jsonc`, agents, commands, and skills.
- Validate the config shape against `https://opencode.ai/config.json` if fields changed or look suspicious.
- Run `stow -n -v -t "$HOME" opencode` from the dotfiles root when appropriate.
- Report conflicts, risky permissions, hardcoded secrets, and whether opencode must be restarted.

User input: $ARGUMENTS
