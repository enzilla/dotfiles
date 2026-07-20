# Dotfiles

Personal configuration files for my development environment, managed with [GNU Stow](https://www.gnu.org/software/stow/).

This repository is organized so each top-level directory is a Stow package. Activating a package creates symlinks from this repo into your home directory, keeping the real files version-controlled here while applications read them from their normal locations under `~/.config`.

## What's Included

| Package | Configures | Target path |
| --- | --- | --- |
| `herdr` | Herdr agent multiplexer | `~/.config/herdr/config.toml` |
| `kitty` | Kitty terminal | `~/.config/kitty` |
| `nvim` | Neovim / LazyVim setup | `~/.config/nvim` |
| `opencode` | opencode agents, skills, commands, MCP templates, and safety defaults | `~/.config/opencode` |
| `pi` | Pi coding agent settings, theme, extensions, and package manifest | `~/.pi/agent` |
| `starship` | Starship prompt | `~/.config/starship.toml` |
| `tmux` | tmux and tmux plugins | `~/.config/tmux` |

## Requirements

- `git`
- `stow`
- The tools you want to configure, such as `herdr`, `nvim`, `tmux`, `kitty`, `pi`, and `starship`

Install Stow with your system package manager:

```sh
# Arch Linux
sudo pacman -S stow

# Debian / Ubuntu
sudo apt install stow

# Fedora
sudo dnf install stow

# macOS
brew install stow
```

## Installation

Clone the repository into your home directory:

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
```

Replace `<repo-url>` with the SSH or HTTPS URL for this repository.

## Activate A Config

Use `stow` from the root of this repository.

For example, to activate the Neovim config:

```sh
cd ~/dotfiles
stow -nv -t "$HOME" nvim
```

The `-n` flag performs a dry run. It shows what Stow would link without changing anything.

If the output looks correct, run the real command:

```sh
stow -v -t "$HOME" nvim
```

That links files from:

```text
~/dotfiles/nvim/.config/nvim
```

to:

```text
~/.config/nvim
```

## Activate More Packages

Activate one package at a time:

```sh
stow --no-folding -v -t "$HOME" herdr
stow -v -t "$HOME" kitty
stow -v -t "$HOME" starship
stow -v -t "$HOME" tmux
stow -v -t "$HOME" opencode
stow -v -t "$HOME" pi
```

Or activate everything currently in this repo:

```sh
stow --no-folding -v -t "$HOME" herdr
stow -v -t "$HOME" kitty nvim opencode pi starship tmux
```

## opencode

The `opencode` package provides a shared global setup for all machines:

- `opencode.jsonc` with unattended permissions, disabled sharing, snapshots, output limits, and optional MCP templates.
- `agent/workbench.md` as the default primary agent for repo and dotfiles work.
- `skills/safe-dotfiles-workflow/SKILL.md` for Stow-aware cross-device configuration changes.
- `command/opencode-check.md`, `command/repo-review.md`, and `command/security-audit.md` for repeatable checks.
- Security-focused skills: `skills/security-audit/` for exploitability audits and `skills/secret-scanning/` for GitHub Secret Protection/push-protection guidance.

Activate it safely with a dry run first:

```sh
cd ~/dotfiles
stow -nv -t "$HOME" opencode
stow -v -t "$HOME" opencode
```

MCP servers are included as disabled templates because they may require network access, browser dependencies, or extra tokens. Enable only the MCPs you trust and use on each machine.

The default workbench auto-approves ordinary tool use. Explicit denials still protect secret paths and destructive shell commands; the built-in plan and explore agents retain their edit blocks without prompting for shell access.

After changing any opencode config, agent, command, skill, plugin, or MCP file, quit and restart opencode. Running sessions keep the config loaded at startup.

## Herdr

The `herdr` package configures the agent multiplexer with the shared Kanagawa Violet palette, transparent terminal background, workspace-grouped agent list, and terminal notifications. It keeps Herdr's default `Ctrl-b` prefix so it does not conflict with tmux's `Ctrl-Space` prefix.

Herdr writes logs, sockets, and session state beside `config.toml`. Keep `~/.config/herdr` as a real directory and link only the config file:

```sh
cd ~/dotfiles
mkdir -p "$HOME/.config/herdr"
stow --no-folding -nv -t "$HOME" herdr
stow --no-folding -v -t "$HOME" herdr
herdr config check
```

If the dry run reports an existing `config.toml`, move that file to a backup first; leave Herdr's logs, sockets, and `session.json` in place.

The user service starts Herdr after reboot. It restores the workspace layout, then resumes supported agent conversations when a client attaches. Running processes cannot survive a reboot; pane history remains off because it may contain secrets.

```sh
systemctl --user daemon-reload
systemctl --user enable herdr.service
loginctl enable-linger "$USER"
```

Install the native integrations for the configured coding agents, then reload or restart each agent:

```sh
herdr integration install pi
herdr integration install opencode
herdr integration install claude
herdr integration status
herdr server reload-config
```

## Pi

The `pi` package configures the [Pi coding agent](https://pi.dev) with:

- a Kanagawa Violet theme that follows Omarchy light/dark mode;
- the existing task, question, fuzzy search, web research, and code-feedback extensions;
- pinned MCP, subagent, provider-usage, permission-gate, and Ponytail packages;
- unattended project trust and permission auto-approval, while explicit secret-path and destructive-command denials remain enforced.

Pi packages run with your user permissions. `"defaultProjectTrust": "always"` removes project trust prompts, and the permission system's `yoloMode` auto-approves every `ask` result. Explicit `deny` rules still block `.env`, credential directories, and `rm -rf`. Package versions are pinned in `settings.json`; install caches, credentials, sessions, and extension logs are deliberately ignored.

Activate it safely:

```sh
cd ~/dotfiles
stow -nv -t "$HOME" pi
```

If the dry run reports the current `settings.json`, `keybindings.json`, or Omarchy extension as a conflict, move only those files to a backup location first. Do not move `auth.json`, `sessions/`, or `npm/`.

Then install the pinned packages and restart Pi:

```sh
stow -v -t "$HOME" pi
sh ~/.pi/agent/install-packages.sh
```

Run `/mcp setup` inside Pi to adopt or create MCP server configuration. Keep server credentials in environment variables or local MCP files, never in this repository.

## Step-By-Step Safe Workflow

1. Clone the repo:

```sh
git clone <repo-url> ~/dotfiles
```

1. Enter the repo:

```sh
cd ~/dotfiles
```

1. Pick the config package you want to enable:

```sh
ls
```

1. Preview the changes with a dry run:

```sh
stow -nv -t "$HOME" nvim
```

1. If Stow reports conflicts, back up or move the existing files first. For example:

```sh
mv ~/.config/nvim ~/.config/nvim.backup
```

1. Run Stow for real:

```sh
stow -v -t "$HOME" nvim
```

1. Open the app and verify the config loads:

```sh
nvim
```

## Deactivate A Config

To remove the symlinks for a package while keeping the files in this repository:

```sh
cd ~/dotfiles
stow -D -v -t "$HOME" nvim
```

This only removes links created by Stow. It does not delete the source files in `~/dotfiles`.

## Updating

Pull the latest changes:

```sh
cd ~/dotfiles
git pull
```

Then re-run Stow for the package you updated:

```sh
stow -v -t "$HOME" nvim
```

## Adding A New Config

Create a new top-level package that mirrors the final location under your home directory.

Example for a hypothetical app named `example`:

```text
dotfiles/
└── example/
    └── .config/
        └── example/
            └── config.toml
```

Then activate it:

```sh
stow -v -t "$HOME" example
```

## Notes

- Always run Stow from the root of this repository.
- Use `stow -n` before activating a new package on a fresh machine.
- Do not copy files manually into `~/.config`; let Stow create symlinks.
- Keep machine-specific secrets out of this repository.
