# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Overview

Personal dotfiles managed via **chezmoi**, targeting macOS (zsh) and Debian Linux (bash).
Chezmoi copies files to `$HOME` using a trait-based system — no symlinks.

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
# Aliases: dt, dots
dotfiles sync          # git pull + apply
dotfiles push [msg]    # commit + git push
dotfiles apply         # apply configs
dotfiles diff          # show pending changes
dotfiles edit <file>   # open a managed file in $EDITOR
dotfiles theme         # interactive Starship theme selector (fzf)
dotfiles secrets       # inject secrets from KeePassXC into ~/.env
dotfiles status        # machine info, traits, managed count
dotfiles info          # active aliases, configs, tools
dotfiles utils         # list utility scripts and fzf functions
dotfiles rollback      # restore a previous snapshot (fzf)
dotfiles doctor        # run chezmoi diagnostics
```

## Repository Structure

```
dotfiles/
├── .chezmoi.toml.tmpl          # Interactive init prompts (machine, traits, font…)
├── .chezmoidata/               # Split data files:
│   ├── profiles.yaml           #   trait definitions + presets
│   ├── aliases.yaml            #   trait_aliases (delta per trait)
│   ├── configs.yaml            #   trait_configs (delta per trait)
│   └── packages.yaml           #   unified cross-platform packages
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

## Trait System

Each machine selects a set of independent traits. Each trait answers one question:

| Trait       | Question                    | Machines            |
|-------------|-----------------------------|---------------------|
| `base`      | Does this machine exist?    | all                 |
| `desktop`   | Does it have a screen?      | bars, nordhealth    |
| `developer` | Do I code on it?            | bars, nordhealth    |
| `personal`  | Is it mine for fun?         | bars                |
| `work`      | Is it for work?             | nordhealth          |

Traits are defined in `.chezmoidata/profiles.yaml`. Each trait's aliases, configs,
and packages are delta-only (list ONLY what the trait adds). The full set is resolved
at template time by iterating all active traits.

Trait gates in `.chezmoiignore` control which files are deployed per machine.
Per-machine overrides: `include_aliases`, `exclude_aliases`, `include_configs`,
`exclude_configs` in `chezmoi.toml`.

## Adding Packages or Aliases

**"Where do I put this?"** — pick the trait that matches:
- Dev tool → `developer` in `.chezmoidata/packages.yaml`
- GUI app → `desktop` in `.chezmoidata/packages.yaml`
- All machines → `base` in `.chezmoidata/packages.yaml`
- New alias file → create in `dot_alias/`, add to the right trait in `.chezmoidata/aliases.yaml`

Package YAML format (supports cross-platform name differences and casks):
```yaml
trait_packages:
  developer:
    - new-tool                            # same name on brew & apt
    - { name: x, apt: x-dev }            # different apt name
    - { name: y, type: cask }            # brew cask (macOS only)
    - { name: z, type: cask, apt: z-app } # cask on macOS, apt name on Linux
```

Packages are installed automatically when the hash of the package list changes on `chezmoi apply`.

Per-machine overrides without changing traits — edit `~/.config/chezmoi/chezmoi.toml`:
```toml
[data]
    include_aliases = ["music"]   # add alias outside active traits
    exclude_aliases = ["tv"]      # skip an alias from active traits
    include_configs = ["mpv"]     # deploy config outside active traits
    exclude_configs = ["zed"]     # skip a config from active traits
```

Then run `chezmoi apply`.

## Naming Conventions

- `dot_foo` → `~/.foo` (hidden file/dir)
- `private_dot_foo` → `~/.foo` with 0600/0700 permissions
- `foo.tmpl` → processed as a Go template before deploying
- `executable_foo` → deployed with +x bit

## Key Configs

- **Shell**: `dot_zshrc.tmpl` — oh-my-zsh + bars theme + Starship; aliases sourced
  from `~/.alias/` based on active traits
- **Git**: `dot_config/git/config.tmpl` — delta pager, user from chezmoi vars;
  `dot_config/git/nordhealth` for work identity (work trait only)
- **Starship**: `dot_config/starship/` — 10+ themes; active set via `chezmoi.toml`
  `data.starship.theme`; switch with `dotfiles theme`
- **Ghostty**: `dot_config/ghostty/config.tmpl` — font from chezmoi vars
- **Zed**: `dot_config/zed/settings.json.tmpl` — font from chezmoi vars
- **Claude Code**: `dot_claude/` — settings.json, CLAUDE.md, rules/

## Machines

| Name        | OS     | Shell | Traits                                |
|-------------|--------|-------|---------------------------------------|
| bars        | macOS  | zsh   | base, desktop, developer, personal    |
| nordhealth  | macOS  | zsh   | base, desktop, developer, work        |
| totoro      | Debian | bash  | base, developer                       |
