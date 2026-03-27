# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Overview

Personal dotfiles managed via **chezmoi**, targeting macOS (zsh) and Debian Linux (bash).
Chezmoi copies files to `$HOME` using a profile-based system — no symlinks.

## Common Commands

```bash
# Apply dotfiles (deploy source to $HOME)
chezmoi apply

# Preview changes without applying
chezmoi apply --dry-run --verbose

# Edit a managed file
chezmoi edit ~/.zshrc

# Show pending changes
chezmoi diff

# Run chezmoi diagnostics
chezmoi doctor

# dotfiles CLI wrapper (installed to ~/.local/bin/dotfiles)
dotfiles sync          # git pull + apply
dotfiles push [msg]    # commit + git push
dotfiles apply         # apply configs
dotfiles diff          # show pending changes
dotfiles theme         # interactive Starship theme selector (fzf)
dotfiles status        # machine info, profiles, managed count
dotfiles doctor        # run chezmoi diagnostics
```

## Repository Structure

```
dotfiles/
├── .chezmoi.toml.tmpl          # Interactive init prompts (machine, profile, font…)
├── .chezmoidata.yaml           # Shared data: profile_aliases, profile_configs, packages
├── .chezmoiignore              # Templated per-machine exclusions
├── .chezmoiscripts/            # Run scripts (bootstrap, packages, oh-my-zsh, python tools)
├── dot_alias/                  # ~/.alias/ — alias files, one per domain
├── dot_claude/                 # ~/.claude/ — Claude Code settings, CLAUDE.md, rules
├── dot_config/                 # ~/.config/ — tool configs (git, ghostty, zed, starship…)
├── dot_local/bin/              # ~/.local/bin/ — executable_dotfiles CLI
├── dot_oh-my-zsh/              # ~/.oh-my-zsh/ — custom themes
├── dot_vim/ + dot_vimrc        # vim config
├── dot_zshrc.tmpl              # ~/.zshrc (templated)
├── private_dot_ssh/            # ~/.ssh/ (0700 dir, 0600 files)
└── install-tools/              # Legacy scripts (reference only, not deployed)
```

## Profile System

Profiles are defined in `.chezmoidata.yaml`. The machine selects one profile in
`.chezmoi.toml.tmpl` and gets a flattened ancestor chain:

| Profile    | Inherits         | Machines               |
|------------|------------------|------------------------|
| `personal` | base + developer | bars, trip laptops     |
| `work`     | base + developer | nordhealth             |
| `server`   | base             | totoro                 |

Profile gates in `.chezmoiignore` control which files are deployed per machine.

## Naming Conventions

- `dot_foo` → `~/.foo` (hidden file/dir)
- `private_dot_foo` → `~/.foo` with 0600/0700 permissions
- `foo.tmpl` → processed as a Go template before deploying
- `executable_foo` → deployed with +x bit

## Key Configs

- **Shell**: `dot_zshrc.tmpl` — oh-my-zsh + bars theme + Starship; aliases sourced
  from `~/.alias/` based on active profile
- **Git**: `dot_config/git/config.tmpl` — delta pager, user from chezmoi vars;
  `dot_config/git/nordhealth` for work identity (work profile only)
- **Starship**: `dot_config/starship/` — 10+ themes; active set via `chezmoi.toml`
  `data.starship.theme`; switch with `dotfiles theme`
- **Ghostty**: `dot_config/ghostty/config.tmpl` — font from chezmoi vars
- **Zed**: `dot_config/zed/settings.json.tmpl` — font from chezmoi vars
- **Claude Code**: `dot_claude/` — settings.json, CLAUDE.md, rules/

## Adding New Aliases

Create a new file in `dot_alias/`, add it to the relevant profile(s) in
`.chezmoidata.yaml` under `profile_aliases`, then run `chezmoi apply`.

## Machines

| Name        | OS     | Shell | Profiles                    |
|-------------|--------|-------|-----------------------------|
| bars        | macOS  | zsh   | base, developer, personal   |
| nordhealth  | macOS  | zsh   | base, developer, work       |
| totoro      | Debian | bash  | base, server                |
