# Dotfiles

Personal configuration files for my development environment, managed with [GNU Stow](https://www.gnu.org/software/stow/).

This repository is organized so each top-level directory is a Stow package. Activating a package creates symlinks from this repo into your home directory, keeping the real files version-controlled here while applications read them from their normal locations under `~/.config`.

## What's Included

| Package | Configures | Target path |
| --- | --- | --- |
| `kitty` | Kitty terminal | `~/.config/kitty` |
| `nvim` | Neovim / LazyVim setup | `~/.config/nvim` |
| `opencode` | opencode agents, skills, commands, MCP templates, and safety defaults | `~/.config/opencode` |
| `starship` | Starship prompt | `~/.config/starship.toml` |
| `tmux` | tmux and tmux plugins | `~/.config/tmux` |

## Requirements

- `git`
- `stow`
- The tools you want to configure, such as `nvim`, `tmux`, `kitty`, and `starship`

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
stow -v -t "$HOME" kitty
stow -v -t "$HOME" starship
stow -v -t "$HOME" tmux
stow -v -t "$HOME" opencode
```

Or activate everything currently in this repo:

```sh
stow -v -t "$HOME" kitty nvim opencode starship tmux
```

## opencode

The `opencode` package provides a shared global setup for all machines:

- `opencode.jsonc` with conservative permissions, disabled sharing, snapshots, output limits, and optional MCP templates.
- `agent/workbench.md` as the default primary agent for repo and dotfiles work.
- `skills/safe-dotfiles-workflow/SKILL.md` for Stow-aware cross-device configuration changes.
- `command/opencode-check.md` and `command/repo-review.md` for repeatable checks.

Activate it safely with a dry run first:

```sh
cd ~/dotfiles
stow -nv -t "$HOME" opencode
stow -v -t "$HOME" opencode
```

MCP servers are included as disabled templates because they may require network access, browser dependencies, or extra tokens. Enable only the MCPs you trust and use on each machine.

After changing any opencode config, agent, command, skill, plugin, or MCP file, quit and restart opencode. Running sessions keep the config loaded at startup.

## Step-By-Step Safe Workflow

1. Clone the repo:

```sh
git clone <repo-url> ~/dotfiles
```

2. Enter the repo:

```sh
cd ~/dotfiles
```

3. Pick the config package you want to enable:

```sh
ls
```

4. Preview the changes with a dry run:

```sh
stow -nv -t "$HOME" nvim
```

5. If Stow reports conflicts, back up or move the existing files first. For example:

```sh
mv ~/.config/nvim ~/.config/nvim.backup
```

6. Run Stow for real:

```sh
stow -v -t "$HOME" nvim
```

7. Open the app and verify the config loads:

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
